SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

# Arguments helper
args = `arg="$(filter-out $@,$(MAKECMDGOALS))" && echo $${arg:-${1}}`

HELPER_COMMANDS = all hello
EXCLUDE_PATTERN = $(shell echo $(HELPER_COMMANDS) | sed 's/ /|/g')  # Might not need

USER_NAME ?= $(USER)
GROUP_NAME ?= $(shell id -g -n $(USER))
DEFAULT_UID := $(shell id -u)
DEFAULT_GID := $(shell id -g)
LOCAL_UID := $(shell id -u $(USER_NAME) 2>/dev/null || echo $(DEFAULT_UID))
LOCAL_GID := $(shell id -g $(GROUP_NAME) 2>/dev/null || echo $(DEFAULT_GID))

# Environment target (local, staging, production), default to local
ENVIRONMENT ?= local
ENV = $(strip $(ENVIRONMENT))

# ------------------------------------------------------------------------------
# Python Setup
# ------------------------------------------------------------------------------
UV_PROJECT_ENVIRONMENT ?= venv

ifndef ($(VIRTUAL_ENV),)
	PYTHON := ./$(UV_PROJECT_ENVIRONMENT)/bin/python
else
	PYTHON := $(shell \
		if command -v python >/dev/null 2>&1; then \
			echo "python"; \
		elif command -v python3.12 >/dev/null 2>&1; then \
			echo "python3.12"; \
		elif command -v python3 >/dev/null 2>&1; then \
			echo "python3"; \
		fi \
	)
endif

ifndef PYTHON
$(error Cannot find a suitable Python executable (checked active VENV, python, python3.12, or python3).)
endif

RUN_TEST ?= pytest
ifneq (,$(wildcard $(PROJECT_DIR)/run-test))
    RUN_TEST := ./run-test
endif

# ------------------------------------------------------------------------------
# Python Commands
# ------------------------------------------------------------------------------

.PHONY: python-install
python-install: # Setup Python Virtual Environment and install dependencies
	@if [ "$(VIRTUAL_ENV)" ]; then \
		echo "Virtual environemnt already activated!" \
		exit 1; \
	fi

	# 1. Remove old environment
	@rm -rf venv || true
	@echo "$(INFO)Old environment removed.$(NC)"

	@echo "Checking for uv installation.."
	@if command -v uv &> /dev/null; \
	then \
		# 2. Create and activate base environment \
		echo "$(H2)uv found. Using uv for fast environment setup.$(NC)"; \
		uv venv venv; \
        source venv/bin/activate; \
		v/bin/activate; \
        echo "$(SUCCESS)Virtual environment created and activated.$(NC)"; \
		\
		# 3. Conditional install for main requirements.txt \
        if [ -f requirements.txt ]; then \
            uv pip install -r requirements.txt; \
            echo "$(SUCCESS)Installed main requirements.txt$(NC)"; \
        else \
            echo "$(ERR)Failed installing requirements, requirements.txt not found.$(NC))"; \
        fi \
		\
        # 4. Conditional install for test requirements-test.txt \
        if [ -f requirements-test.txt ]; then \
            uv pip install -r requirements-test.txt; \
            echo "$(SUCCESS)Installed test requirements-test.txt$(NC)"; \
        else \
            echo "$(ERR)Failed installing requirements-test, requirements-test.txt not found.$(NC)"; \
        fi \
	else \
		# --- FALLBACK MODE (Standard VENV + PIP) --- \
		echo "$(H2)uv not found. cringe.$(NC)"; \
		\
		# 2. Create and activate base environment using standard venv \
        python -m venv venv; \
        source venv/bin/activate; \
        echo "$(SUCCESS)Virtual environment created and activated.$(NC)"; \
		\
        # 3. Conditional sync for main requirements.txt \
        if [ -f requirements.txt ]; then \
            pip install -r requirements.txt; \
            echo "$(SUCCESS)Installed main requirements.txt$(NC)"; \
        else \
            echo "$(ERR)Failed installing requirements, requirements.txt not found.$(NC)"; \
        fi \
		\
        # 4. Conditional sync for test requirements-test.txt \
        if [ -f requirements-test.txt ]; then \
            pip install -r requirements-test.txt; \
            echo "$(SUCCESS)Installed test requirements-test.txt$(NC)"; \
        else \
            echo "$(ERR)Failed installing requirements-test, requirements-test.txt not found.$(NC)"; \
        fi \
	fi

.PHONY: python-test
python-test: # Run python unit tests
	@echo "$(H1)Running tests..$(NC)"
	@if [ -z "$(TEST_PATH)" ]; then \
		printf "Running $(H2)all tests$(NC)\n"; \
	else \
		printf "Running tests for path: $(H2)$(TEST_PATH)$(NC)\n"; \
	fi

	@$(EXEC_CMD) $(RUN_TEST) $(TEST_PATH);

.PHONY: python-lint
python-lint: # Run linting with pre-commit
	@echo "$(H1)Running lint..$(NC)"
	@make check-non-deploy-env-only
# 	@make check-python-pre-commit # TODO

	@$(EXEC_CMD) pre-commit run --all-files

.PHONY: python-format
python-format: # Run auto-formatting
	@echo "$(H1)Running formatter..$(NC)"
	@make check-non-deploy-env-only
# 	@make check-python-black # TODO

	@$(EXEC_CMD) -m black .

# ------------------------------------------------------------------------------
# Django Setup
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Django Commands
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Docker Setup
# ------------------------------------------------------------------------------

DOCKER_DIR ?= docker
ifeq ($(ENV),local)
	COMPOSE_PROFILES := dev
	DOCKER_BUILD_FILE = $(DOCKER_DIR)/Dockerfile.local
	DOCKER_COMPOSE_FILE ?= $(DOCKER_DIR)/docker-compose.local.yaml
else ifeq ($(ENV),staging)
	COMPOSE_PROFILES := deploy
	DOCKER_BUILD_FILE = $(DOCKER_DIR)/Dockerfile.deploy
	DOCKER_COMPOSE_FILE ?= $(DOCKER_DIR)/docker-compose.staging.yaml
else
	COMPOSE_PROFILES := deploy
	DOCKER_BUILD_FILE = $(DOCKER_DIR)/Dockerfile.deploy
	DOCKER_COMPOSE_FILE ?= $(DOCKER_DIR)/docker-compose.production.yaml
endif

HOST_WEB_PORT?= 8000
HOST_POSTGRES_PORT ?= 5432

POSTGRES_HOST ?= default_host
POSTGRES_DB ?= default_db
POSTGRES_USER ?= $(USER_NAME)
POSTGRES_PASSWORD ?= $(USER_NAME)
POSTGRES_PORT ?= 5432

TAG ?= latest.$(ENV)
SERVICE ?= web
TARGET ?= $(PROJECT_NAME)-$(SERVICE)

# Environment variables to be passed to the shell before docker-compose.
DOCKER_COMPOSE_ENV_VARS = COMPOSE_PROFILES=$(COMPOSE_PROFILES) \
	POSTGRES_HOST=$(POSTGRES_HOST) \
	POSTGRES_DB=$(POSTGRES_DB) \
	POSTGRES_USER=$(POSTGRES_USER) \
	POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
	POSTGRES_PORT=$(POSTGRES_PORT) \
	HOST_WEB_PORT=$(HOST_WEB_PORT) \
	HOST_POSTGRES_PORT=$(HOST_POSTGRES_PORT) \
	LOCAL_UID=$(LOCAL_UID) \
	LOCAL_GID=$(LOCAL_GID) \
	USER_NAME=$(USER_NAME) \
	GROUP_NAME=$(GROUP_NAME) \
	TAG=$(TAG)

# Common variables for docker-compose (used for up, down , log, etc)
DOCKER_COMPOSE_ARGS = -f $(DOCKER_COMPOSE_FILE) \
	-p $(PROJECT_NAME) \
	--env-file .env \
	--progress=plain

ifeq ($(IN_DOCKER),true)
	undefine EXEC_CMD
	MANAGE_CMD = python manage.py
else
	IN_DOCKER=false
	EXEC_CMD := docker exec -it $(TARGET)
	MANAGE_CMD = $(EXEC_CMD) python manage.py
endif

# ------------------------------------------------------------------------------
# Docker Commands
# ------------------------------------------------------------------------------

.PHONY: docker-build
docker-build: # Build the services for environment
	@echo "Building $(GREEN)$(TARGET)$(NC) for environment: $(GREEN)$(ENV)$(NC)"
	@docker build \
	-f $(DOCKER_BUILD_FILE) \
	-t $(PROJECT_NAME):$(TAG) \
	--build-arg LOCAL_UID=$(LOCAL_UID) \
	--build-arg LOCAL_GID=$(LOCAL_GID) \
	--progress=plain .
	@echo "Image built: ghcr.io/???:$(TAG)"
	@echo "Next step usually is to run '$(GREEN)make up$(NC)' "
	@echo "Run '$(GREEN)make help$(NC)' for more commands"

.PHONY: docker-up
docker-up: # Start the services in detached mode for environment
	@echo "Starting $(GREEN)$(TARGET)$(NC) for environment: $(GREEN)$(ENV)$(NC)"
	@$(DOCKER_COMPOSE_ENV_VARS) \
	docker-compose \
	$(DOCKER_COMPOSE_ARGS) \
	up -d --remove-orphans
	@echo "Services started for environment: $(GREEN)$(ENV)$(NC)"
	@echo "To view logs, run '$(GREEN)make logs$(NC)'"
	@echo "Next step usually is to run '$(GREEN)DB_BACKUP=path/to/backup/file.db make restore-db$(NC)'"
	@echo "simply '$(GREEN)DB_BACKUP=file.db make restore-db$(NC)' if in the same directory "
	@echo "Run '$(GREEN)make help$(NC)' for more commands"

.PHONY: docker-down
docker-down: # Stop the services in environment
	@echo "TODO"

.PHONY: docker-restart
docker-restart: # Restart a specific service in environment
	@echo "TODO"

.PHONY: docker-log docker-logs
docker-log docker-logs: # View logs for specific service in environment
	@echo "TODO"

.PHONY: docker-clean-container docker-clean-containers
docker-clean-container docker-clean-containers: # Clean up unused Docker containers
	@echo "Cleaning up unused Docker containers.."
	@make check-in-docker-reject
	@docker container prune -f --filter "label=project=$(PROJECT_NAME)"

.PHONY: docker-clean-image docker-clean-images
docker-clean-image docker-clean-images: # Clean up unused Docker images
	@echo "Cleaning up unused Docker images.."
	@make check-in-docker-reject
	@docker image prune -a -f --filter "label=project=$(PROJECT_NAME)"

.PHONY: docker-clean-volume docker-clean-volumes
docker-clean-volume docker-clean-volumes: # Clean up unused Docker volumes
	@echo "Cleaning up unused Docker volumes.."
	@make check-in-docker-reject
	@docker volume prune -f --filter "label=project=$(PROJECT_NAME)"

.PHONY: docker-clean-network
docker-clean-network: # Clean up unused Docker networks
	@echo "Cleaning up unused Docker networks.."
	@make check-in-docker-reject
	@docker network prune -f --filter "label=project=$(PROJECT_NAME)"

.PHONY: docker-clean
docker-clean: # Clean up unused Docker resources (containers, images, volumes)
	@echo "$(H1)Cleaning up unused Docker resources..$(NC)"
	@make check-in-docker-reject
	@make docker-clean-containers
	@make docker-clean-image
	@make docker-clean-volume
	@docker buildx prune -f
	@docker network prune -f --filter "label=project=$(PROJECT_NAME)"
	@docker system prune --volumes -af --filter "label=project=$(PROJECT_NAME)"

.PHONY: docker-purge
docker-purge: # Purge all Docker resources (containers, images, volumes, networks)
	@echo "$(RED)WARNING$(NC): This command will $(RED)remove ALL stopped$(NC) $(YELLOW)containers$(NC), $(RED)ALL unused$(NC) $(YELLOW)images$(NC), and $(RED)ALL unused$(NC) $(YELLOW)volumes$(NC)"
	@echo "This is a $(RED)destructive$(NC) operation and may effect $(RED)ALL$(NC) your Docker projects."
	@make _yes-no-prompt
	@echo "$(RED)Purging all Docker resources..$(NC)"
	@make check-in-docker-reject
	@docker container prune -f
	@docker image prune -a -f
	@docker volume prune -f
	@docker network prune -f
	@docker buildx prune -f
	@docker system prune --volumes -af

### Special targets for arguments
%:
	@:
