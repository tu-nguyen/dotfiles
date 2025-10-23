include .env

include ./shared/style.mk
include ./shared/default.mk
include ./shared/base.mk
# include ./shared/docker.mk
# include ./shared/python.mk
# include ./shared/postgres.mk

SHELL := /bin/bash

## Help and variable check
hello: # Default help command
	@echo "hello"

### Shared commands
help ::
# 	@printf "$(H2)Shared Commands$(NC)\n"
# 	@printf "    $(GREEN)help$(NC): Default help command\n"
	# docker
	@printf "$(H2)Docker Commands$(NC)\n"
	@printf "    $(GREEN)docker-status$(NC): List containers for environment\n"
	@printf "    $(GREEN)docker-image docker-images$(NC): List images for environment\n"
	@printf "    $(GREEN)docker-pull$(NC): Pull the services\n"
	@printf "    $(GREEN)docker-push$(NC): Push the services (only for deploy)\n"
	@printf "    $(GREEN)docker-build$(NC): Build the services for environment\n"
	@printf "    $(GREEN)docker-rebuild$(NC): Rebuild the services (no cache)\n"
	@printf "    $(GREEN)docker-up$(NC): Start the services in detached mode for environment\n"
	@printf "    $(GREEN)docker-down$(NC): Stop the services in environment\n"
	@printf "    $(GREEN)docker-restart$(NC): Restart a specific service in environment\n"
	@printf "    $(GREEN)docker-build-up$(NC): Build and start the services in detached mode for environment\n"
	@printf "    $(GREEN)docker-log docker-logs$(NC): View logs for specific service in environment\n"
	@printf "    $(GREEN)docker-clean-container docker-clean-containers:$(NC): Clean up unused Docker containers\n"
	@printf "    $(GREEN)docker-clean-image docker-clean-images:$(NC): Clean up unused Docker images\n"
	@printf "    $(GREEN)docker-clean-volume docker-clean-volumes$(NC): Clean up unused Docker volumes\n"
	@printf "    $(GREEN)docker-clean-network$(NC): Clean up unused Docker networks\n"
	@printf "    $(GREEN)docker-clean$(NC):  Clean up unused Docker resources (containers, images, volumes)\n"
	@printf "    $(GREEN)docker-purge$(NC):  Purge all Docker resources (containers, images, volumes, networks)\n"
	@printf "    $(GREEN)docker-bash docker-shell:$(NC):  Shell into running container\n"


