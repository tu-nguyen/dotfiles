DOCKER_DIR = docker
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

# ARCH target (amd64, arm64), default to amd64
ARCH_TEMP ?= amd64
ARCH ?= $(strip $(ARCH_TEMP))
TAG ?= latest.$(ENV)-$(ARCH)
PORT_OFFSET ?= 0

# Service target (web, db, etc), default to web
SERVICE ?= web
SUBDOMAIN ?= $(PROJECT_NAME)
TARGET ?= $(PROJECT_NAME)-$(SERVICE)



# Docker Exec command helper (generic)
ifeq ($(GITHUB_ACTIONS),true)
	EXEC_CMD := docker exec $(TARGET)
else
	ifeq ($(filter dump backup-db pg_dump restore-db,$(MAKECMDGOALS)),)
		EXEC_CMD := docker exec -it $(TARGET)
	else
		EXEC_CMD := docker exec -e PGPASSWORD=$(POSTGRES_PASSWORD) $(TARGET)
	endif
endif

ifeq ($(INTERACTIVE),false)
	EXEC_CMD := $(EXEC_CMD)
endif

# *** Environment variables to be passed to the shell before docker-compose.
DOCKER_COMPOSE_ENV_VARS = COMPOSE_PROFILES=$(COMPOSE_PROFILES) \
	PROJECT_HOST_DIR=$(PROJECT_HOST_DIR) \
	POSTGRES_HOST=$(POSTGRES_HOST) \
	POSTGRES_DB=$(POSTGRES_DB) \
	POSTGRES_USER=$(POSTGRES_USER) \
	POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
	POSTGRES_PORT=$(POSTGRES_PORT) \
	TAG=$(TAG)

# Common variables for docker-compose (used for both up and checking status)
DOCKER_COMPOSE_ARGS = -f $(COMPOSE_FILE) \
	-p $(PROJECT_NAME) \
	--env-file .env \
	--progress=plain

## Test
docker-status: # List containers for environment
	@echo "Listing containers for environment: $(GREEN)$(ENV)$(NC)"
	@make check-in-docker-reject
	@$(DOCKER_COMPOSE_ENV_VARS) \
	docker-compose \
	$(DOCKER_COMPOSE_ARGS) \
	ps --format '{{.ID}} - {{.Names}} - {{.Image}} - {{ .Ports }} - {{.Status}}'

docker-image docker-images: # List images for environment
	@echo "Listing images for environment: $(GREEN)$(ENV)$(NC)"
	@make check-in-docker-reject
	@docker images --format '{{.ID}}: {{.Repository}}:{{.Tag}} - {{.Size}}'

docker-pull: # Pull the services
	@echo "Pulling for environment: $(GREEN)$(ENV)$(NC)"
	@make check-in-docker-reject
	@docker pull ghcr.io/rsginc/rmove-central:$(TAG)

docker-push: # Push the services (only for deploy)
	@echo "Pushing for environment: $(GREEN)$(ENV)$(NC)"
	@make check-in-docker-reject
	@if [ -z "$(FORCE_YES)" ]; then \
		read -p "Are you sure you want to push the image? [y/N] " -n 1 -r; \
		echo ""; \
		if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
			echo "Exiting.."; \
			exit 1; \
		fi; \
	fi
	@docker push ghcr.io/rsginc/rmove-central:$(TAG)

docker-build: # Build the services for environment
	@echo "Building $(GREEN)$(TARGET)$(NC) for environment: $(GREEN)$(ENV)$(NC)"
	@make check-in-docker-reject
	@docker build \
	-f $(BUILD_FILE) \
	-t ghcr.io/rsginc/rmove-central:$(TAG) \
	--build-arg LOCAL_UID=$(LOCAL_UID) \
	--build-arg LOCAL_GID=$(LOCAL_GID) \
	--progress=plain .
	@echo "Image built: ghcr.io/rsginc/rmove-central:$(TAG)"
	@echo "Next step usually is to run '$(GREEN)make up$(NC)' "
	@echo "Run '$(GREEN)make help$(NC)' for more commands"

docker-rebuild: # Rebuild the services (no cache)
	@echo "Re-building $(GREEN)$(TARGET)$(NC) for environment: $(GREEN)$(ENV)$(NC)"
	@make check-in-docker-reject
	@docker build \
	--no-cache \
	-f $(BUILD_FILE) \
	-t ghcr.io/rsginc/rmove-central:$(TAG) \
	--build-arg LOCAL_UID=$(LOCAL_UID) \
	--build-arg LOCAL_GID=$(LOCAL_GID) \
	--progress=plain .
	@echo "Image built: ghcr.io/rsginc/rmove-central:$(TAG)"
	@echo "Next step usually is to run '$(GREEN)make up$(NC)'"
	@echo "Run '$(GREEN)make help$(NC)' for more commands"

docker-up: # Start the services in detached mode for environment
	@make check-rmove-network
	@make check-port
	@echo "Starting $(GREEN)$(TARGET)$(NC) for environment: $(GREEN)$(ENV)$(NC)"
	@make check-in-docker-reject
	@make check-data_dir
	@$(DOCKER_COMPOSE_ENV_VARS) \
	docker-compose \
	$(DOCKER_COMPOSE_ARGS) \
	up -d --remove-orphans
	@echo "Services started for environment: $(GREEN)$(ENV)$(NC)"
	@echo "To view logs, run '$(GREEN)make logs$(NC)'"
	@echo "Next step usually is to run '$(GREEN)DB_BACKUP=path/to/backup/file.db make restore-db$(NC)'"
	@echo "simply '$(GREEN)DB_BACKUP=file.db make restore-db$(NC)' if in the same directory "
	@if [ -n "$$(docker ps -q -f name=caddy)" ]; then \
        echo "Caddy is running. You can view the current domains by running $(GREEN)make caddy-ls$(NC)"; \
    else \
        echo "Caddy is $(BOLD)$(RED)NOT$(NC) running. Start it with $(GREEN)make caddy-up$(NC)"; \
    fi
	@echo "Run '$(GREEN)make help$(NC)' for more commands"

docker-down: # Stop the services in environment
	@echo "Stopping $(GREEN)$(TARGET)$(NC) for environment: $(GREEN)$(ENV)$(NC)"
	@make check-in-docker-reject
	@$(DOCKER_COMPOSE_ENV_VARS) \
	docker-compose \
	$(DOCKER_COMPOSE_ARGS) \
	down
	@echo "Services stopped for environment: $(GREEN)$(ENV)$(NC)"
	@echo "Consider running '$(GREEN)make clean$(NC)' to remove unused resources"

docker-restart: # Restart a specific service in environment
	@echo "Restarting service: $(GREEN)$(TARGET)$(NC) in environment $(GREEN)$(ENV)$(NC)"
	@make check-in-docker-reject
	@$(DOCKER_COMPOSE_ENV_VARS) \
	docker-compose \
	$(DOCKER_COMPOSE_ARGS) \
	restart
	@echo "Service restarted: $(GREEN)$(TARGET)$(NC) in environment $(GREEN)$(ENV)$(NC)"

docker-build-up: # Build and start the services in detached mode for environment
	@echo "Building and starting services for environment: $(GREEN)$(ENV)$(NC)"
	@make check-in-docker-reject
	@make build
	@make up

docker-log docker-logs: # View logs for specific service in environment
	@echo "Showing logs for service $(GREEN)$(SERVICE)$(NC) in environment $(GREEN)$(ENV)$(NC)"
	@echo "To view other services, run '$(GREEN)make logs SERVICE=service_name$(NC)'"
	@make check-in-docker-reject
	@$(DOCKER_COMPOSE_ENV_VARS) \
	docker-compose \
	$(DOCKER_COMPOSE_ARGS) \
	logs -f $(SERVICE) | { if [ -n "$(GREP)" ]; then grep --color=auto "$(GREP)"; else cat; fi; }

docker-clean-container clean-containers: # Clean up unused Docker containers
	@echo "Cleaning up unused Docker containers.."
	@make check-in-docker-reject
	@docker container prune -f --filter "label=project=$(PROJECT_NAME)"

docker-clean-image clean-images: # Clean up unused Docker images
	@echo "Cleaning up unused Docker images.."
	@make check-in-docker-reject
	@docker image prune -a -f --filter "label=project=$(PROJECT_NAME)"

docker-clean-volume clean-volumes: # Clean up unused Docker volumes
	@echo "Cleaning up unused Docker volumes.."
	@make check-in-docker-reject
	@docker volume prune -f --filter "label=project=$(PROJECT_NAME)"

docker-clean-network: # Clean up unused Docker networks
	@echo "Cleaning up unused Docker networks.."
	@make check-in-docker-reject
	@docker network prune -f --filter "label=project=$(PROJECT_NAME)"

docker-clean: # Clean up unused Docker resources (containers, images, volumes)
	@echo "Cleaning up unused Docker resources.."
	@make docker-check-in-docker-reject
	@make docker-clean-containers
	@make docker-clean-image
	@make docker-clean-volume
	@docker buildx prune -f
	@docker network prune -f --filter "label=project=$(PROJECT_NAME)"
	@docker system prune --volumes -af --filter "label=project=$(PROJECT_NAME)"

docker-purge: # Purge all Docker resources (containers, images, volumes, networks)
	@echo "$(RED)WARNING$(NC): This command will $(RED)remove ALL stopped$(NC) $(YELLOW)containers$(NC), $(RED)ALL unused$(NC) $(YELLOW)images$(NC), and $(RED)ALL unused$(NC) $(YELLOW)volumes$(NC)"
	@echo "This is a $(RED)destructive$(NC) operation and may effect $(RED)ALL$(NC) your Docker projects."
	@if [ -z "$(FORCE_YES)" ]; then \
		read -p "Are you sure you want to proceed? [y/N] " -n 1 -r; \
		echo ""; \
		if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
			echo "Exiting.."; \
			exit 1; \
		fi; \
	fi
	@echo "Purging all Docker resources.."
	@make check-in-docker-reject
	@docker container prune -f
	@docker image prune -a -f
	@docker volume prune -f
	@docker network prune -f
	@docker buildx prune -f
	@docker system prune --volumes -af

docker-bash docker-shell: # Shell into running container
	@echo "Opening shell for service: $(GREEN)$(TARGET)$(NC) in environment $(GREEN)$(ENV)$(NC)"
	@if [ $(IN_DOCKER) = "true" ]; then \
		echo "Already inside container"; \
	else \
		$(EXEC_CMD) /bin/bash; \
	fi

docker-psql: # Shell into running db container
	@echo "Opening psql for service: $(GREEN)$(TARGET)$(NC) in environment $(GREEN)$(ENV)$(NC)"
	@TARGET=${PROJECT_NAME}-${POSTGRES_HOST:-db} $(EXEC_CMD) psql -U $(POSTGRES_USER) -d $(POSTGRES_DB)
