include .env

include ./shared/style.mk
include ./shared/default.mk
include ./shared/base.mk

SHELL := /bin/bash

PROJECT_NAME ?= $(shell basename $$(pwd))
PROJECT_DIR := $(CURDIR)
export PROJECT_NAME
export PROJECT_DIR

# How to use:
# look at base.mk and helper.mk
# if any commands uses variable set here
# be sure to export so it's available to the mks
# LOCAL_UID ?= 1000
# LOCAL_GID ?= 1000
# export LOCAL_UID
# export LOCAL_GID

# If the project is python base
# your install command can call python-install
.PHONY: install
install:          ## Initialize Python venv and install requirements.txt and requirements-test.txt.
	@make python-install

## Help and variable check
.PHONY: help
help: # Default help command
	@echo "$(H1)Usage$(NC):"
	@echo "  make [command] <arg>"
	@echo "           make install"
	@echo "           make logs db"
	@echo "           make test tests/api/test_set_locale.py"
	@echo "  $(H2)**Note you can also override variables**$(NC):"
	@echo "           make install PYTHON=python3.12"
	@echo "$(H1)Environment Variables:$(NC) (run '$(GREEN)make make-check$(NC)' to see more)"
	@echo "  ENV: $(ENV)"
	@echo "  TARGET: $(TARGET)"
	@echo "  TAG: $(TAG)"
	@echo "$(H1)Common Commands:$(NC) $(GREEN)install, logs, test, lint, clean, help$(NC)"
	@echo "$(H1)Available Commands:$(NC)"
	@grep -E '^(## |[a-zA-Z0-9 _-]+:.*#)' Makefile | grep -v '^###' | grep -Ev "^($(EXCLUDE_PATTERN)):" | while read -r line; do \
		if echo "$$line" | grep -q '^##'; then \
			printf "$(H2)$$(echo $$line | sed 's/^## //')$(NC)\n"; \
		else \
			cmd=$$(echo $$line | cut -f 1 -d':'); \
			desc=$$(echo $$line | cut -f 2- -d'#'); \
			printf "    $(GREEN)$$cmd$(NC):$$desc\n"; \
		fi; \
	done

make-check: # Check current environment variable
	@make _make-check-default
	@make _make-check-python
	@make _make-check-django
	@make _make-check-docker
