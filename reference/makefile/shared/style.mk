# Terminal Color Definitions and Style Attributes

# Check if tput is available before attempting to define colors
ifeq ($(shell command -v tput 2>/dev/null),)
	RED :=
	GREEN :=
	YELLOW :=
	BLUE :=
	MAGENTA :=
	CYAN :=
	WHITE :=
	PINK :=
	BOLD :=
	UNDERLINE :=
	NC :=
else
	RED = $(shell tput setaf 1)
	GREEN = $(shell tput setaf 2)
	YELLOW = $(shell tput setaf 3)
	BLUE := $(shell tput setaf 4)
	MAGENTA = $(shell tput setaf 5)
	CYAN = $(shell tput setaf 6)
	WHITE = $(shell tput setaf 7)
	PINK = $(shell echo -e '\033[38;5;205m')

	BOLD = $(shell tput bold)
	UNDERLINE = $(shell tput smul)
	NC := $(shell tput sgr0)
endif

H1 = $(BOLD)$(CYAN)
H2 = $(BOLD)$(PINK)
SUCCESS = $(BOLD)$(GREEN)
INFO = $(BOLD)$(CYAN)
ERR = $(BOLD)$(RED)
