DEFAULT_UID := $(shell id -u)
DEFAULT_GID := $(shell id -g)

# Get UID and GID from the environment or use defaults
LOCAL_UID := $(shell id -u $(USER_NAME) 2>/dev/null || echo $(DEFAULT_UID))
LOCAL_GID := $(shell id -g $(GROUP_NAME) 2>/dev/null || echo $(DEFAULT_GID))
