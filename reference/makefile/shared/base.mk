SHELL := /bin/bash

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

.PHONY: help
## Help and variable check
help :: # Default help command
	@echo "$(H1)Usage$(NC):"
	@echo "  make [command] <>"
	@echo "  examples:"
	@echo "           make build"
	@echo "           make logs db"
	@echo "           make test tests/api/test_set_locale.py"
	@echo "$(H1)Environment Variables:$(NC) (run '$(GREEN)make make-check$(NC)' to see more)"
	@echo "  ENV: $(ENV)"
	@echo "  TARGET: $(TARGET)"
	@echo "  TAG: $(TAG)"
	@echo "$(H1)Common Commands:$(NC) $(GREEN)build, up, logs, test, lint, help$(NC)"
	@echo "$(H1)Available Commands:$(NC)"
# 	@grep -E '^(## |[a-zA-Z0-9 _-]+:.*#)' Makefile | grep -v '^###' | grep -Ev "^($(EXCLUDE_PATTERN)):" | while read -r line; do \
# 		if echo "$$line" | grep -q '^##'; then \
# 			printf "$(H2)$$(echo $$line | sed 's/^## //')$(NC)\n"; \
# 		else \
# 			cmd=$$(echo $$line | cut -f 1 -d':'); \
# 			desc=$$(echo $$line | cut -f 2- -d'#'); \
# 			printf "    $(GREEN)$$cmd$(NC):$$desc\n"; \
# 		fi; \
# 	done
	@grep -E '^(## |[a-zA-Z0-9 _-]+::?.*#)' Makefile | grep -v '^###' | grep -Ev "^($(EXCLUDE_PATTERN)):" | while read -r line; do \
        if echo "$$line" | grep -q '^##'; then \
            printf "$(H2)$$(echo $$line | sed 's/^## //')$(NC)\n"; \
        else \
            cmd=$$(echo $$line | cut -f 1 -d':'); \
            desc=$$(echo $$line | cut -f 2- -d'#'); \
            printf "    $(GREEN)$$cmd$(NC):$$desc\n"; \
        fi; \
    done

.SILENT: # Suppress command output

### Special targets for arguments
%:
	@:
