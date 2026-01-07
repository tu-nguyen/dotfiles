CHECK_CMD = command -v $(1) >/dev/null 2>&1 || (echo "ERROR: $(1) is NOT installed or not in PATH." && exit 1)

args = `arg="$(filter-out $@,$(MAKECMDGOALS))" && echo $${arg:-${1}}`
TEST_PATH = $(call args,)

_yes-no-prompt:
	@if [ -z "$(FORCE_YES)" ]; then \
		read -p "Are you sure you want to proceed? [y/N] " -n 1 -r; \
		echo ""; \
		if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
			echo "Exiting.."; \
			exit 1; \
		fi; \
	fi

_make-check-default:
	@echo "$(H1)Makefile Variables$(NC):"
	@echo "  $(H2)PROJECT_NAME$(NC): $(PROJECT_NAME)"
	@echo "  $(H2)PROJECT_DIR$(NC): $(PROJECT_DIR)"
	@echo "  $(H2)ENV$(NC): $(ENV)"
	@echo "  $(H2)USER_NAME$(NC): $(USER_NAME)"
	@echo "  $(H2)GROUP_NAME$(NC): $(GROUP_NAME)"
	@echo "  $(H2)LOCAL_UID$(NC): $(LOCAL_UID)"
	@echo "  $(H2)LOCAL_GID$(NC): $(LOCAL_GID)"

_make-check-python:
	@echo "$(H1)Python Variables$(NC):"
	@echo "  $(H2)PYTHON$(NC): $(PYTHON)"
	@echo "  $(H2)VIRTUAL_ENV$(NC): $(VIRTUAL_ENV)"

_make-check-django:
	@echo "$(H1)Django Variables$(NC):"
	@echo "  $(H2)MANAGE_CMD$(NC): $(MANAGE_CMD)"

_make-check-docker:
	@echo "$(H1)Docker Variables$(NC):"
	@echo "  $(H2)EXEC_CMD$(NC): $(EXEC_CMD)"

# ---------------------------------------------------------------------
# Check installations
# ---------------------------------------------------------------------

check-npm: # Check if npm is installed
	@echo "$(H2)Checking for $(GREEN)npm$(NC)"
	@$(call CHECK_CMD,npm)
	@echo "$(GREEN)npm found.$(NC)"

check-java: # Check if java is installed
	@echo "$(H2)Checking for $(GREEN)java$(NC)"
	@$(call CHECK_CMD,java)
	@echo "$(GREEN)java found.$(NC)"

# ---------------------------------------------------------------------
# Check environments
# ---------------------------------------------------------------------

check-container-running: # Check if the container is running
	@echo "$(H2)Checking if container is running$(NC)"
	@if [ -z "$$(docker ps -q -f name=$(TARGET))" ]; then \
		echo "Container $(RED)$(TARGET)$(NC) is not running"; \
		CONTAINER_RUNNING=False; \
	else \
		echo "Container $(GREEN)$(TARGET)$(NC) is running"; \
		CONTAINER_RUNNING=true; \
	fi

check-local-env-only: # Check local environment only
	@echo "$(H2)Checking local environment only$(NC)"
	@if [ "$(ENV)" != "local" ]; then \
		echo "Current environment set to $(RED)$(ENV)$(NC)"; \
		echo "$(ERR)This command is only allowed for local environment$(NC)"; \
		exit 1; \
	fi

check-local-env-reject: # Check local environment reject
	@echo "$(H2)Checking local environment reject$(NC)"
	@if [ "$(ENV)" = "local" ]; then \
		echo "Current environment set to $(RED)$(ENV)$(NC)"; \
		echo "$(ERR)This command is not allowed for local environment$(NC)"; \
		exit 1; \
	fi

check-non-deploy-env-only: # Check if environment is not staging or production only
	@echo "$(H2)Checking non-deploy environment only$(NC)"
	@if [ "$(ENV)" = "staging" ] || [ "$(ENV)" = "production" ]; then \
		echo "Current environment set to $(RED)$(ENV)$(NC)"; \
		echo "$(ERR)This command is only allowed for local and test environment$(NC)"; \
		exit 1; \
	fi

check-non-deploy-env-reject: # Check if environment is not staging or production reject
	@echo "$(H2)Checking non-deploy environment reject$(NC)"
	@if [ "$(ENV)" != "staging" ] && [ "$(ENV)" != "production" ]; then \
		echo "Current environment set to $(RED)$(ENV)$(NC)"; \
		echo "$(ERR)This command is not allowed for local and test environment$(NC)"; \
		exit 1; \
	fi

check-in-docker-only: # Check if running in Docker only
	@echo "$(H2)Checking in Docker only$(NC)"
	@if [ "$(IN_DOCKER)" = "true" ]; then \
		echo "$(ERR)This command is not allowed when running in Docker$(NC)"; \
		exit 1; \
	fi

check-in-docker-reject: # Check if running in Docker reject
	@echo "$(H2)Checking in Docker reject$(NC)"
	@if [ "$(IN_DOCKER)" = "true" ]; then \
		echo "$(ERR)This command is not allowed when running in Docker$(NC)"; \
		exit 1; \
	fi
