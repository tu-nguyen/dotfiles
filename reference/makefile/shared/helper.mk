SHELL := /bin/bash

# Colors for output
NC = $(shell tput sgr0)
RED = $(shell tput setaf 1)
GREEN = $(shell tput setaf 2)
YELLOW = $(shell tput setaf 3)
MAGENTA = $(shell tput setaf 5)
CYAN = $(shell tput setaf 6)
PINK = $(shell echo -e '\033[38;5;205m')

BOLD = $(shell tput bold)

H1 = $(BOLD)$(CYAN)
H2 = $(BOLD)$(PINK)

# Arguments helper
args = `arg="$(filter-out $@,$(MAKECMDGOALS))" && echo $${arg:-${1}}`

HELPER_COMMANDS = all
EXCLUDE_PATTERN = $(shell echo $(HELPER_COMMANDS) | sed 's/ /|/g')

test ::
	@echo "test from mk"

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
