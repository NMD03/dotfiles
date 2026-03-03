.PHONY: all delete ubuntu arch macos

OS := $(shell uname -s)
DISTRO := $(if $(findstring Linux,$(OS)),$(shell awk -F= '$$1=="NAME" { gsub(/"/, "", $$2); print $$2 }' /etc/os-release))
ROOT := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
XDG_CONFIG_HOME ?= $(HOME)/.config

STOW_RESTOW := stow --verbose --dotfiles --restow
STOW_DELETE := stow --verbose --dotfiles --delete

all: general $(OS)

general:
	$(STOW_RESTOW) -d $(ROOT)/ -t $(XDG_CONFIG_HOME) CONFIG
	$(STOW_RESTOW) -d $(ROOT)/ -t $(HOME) HOME
	sudo $(STOW_RESTOW) -d $(ROOT)/ -t /etc ETC

# Linux specific configurations
Linux:
	$(STOW_RESTOW) -d $(ROOT)/OS/Linux -t $(XDG_CONFIG_HOME) CONFIG
	$(STOW_RESTOW) -d $(ROOT)/OS/Linux -t $(HOME) HOME
	sudo $(STOW_RESTOW) -d $(ROOT)/OS/Linux -t /etc ETC
	@if [ "$(DISTRO)" = "Ubuntu" ]; then \
		echo "Applying Ubuntu-specific configurations..."; \
		$(MAKE) ubuntu; \
	elif [ "$(DISTRO)" = "Arch Linux" ]; then \
		echo "Applying Arch-specific configurations..."; \
		$(MAKE) arch; \
	elif [ "$(DISTRO)" = "Fedora Linux" ]; then \
		echo "Applying Fedora-specific configurations..."; \
		$(MAKE) fedora; \
	fi

ubuntu:
	$(STOW_RESTOW) -d $(ROOT)/OS/Linux/ubuntu -t $(XDG_CONFIG_HOME) CONFIG
	$(STOW_RESTOW) -d $(ROOT)/OS/Linux/ubuntu -t $(HOME) HOME
	sudo $(STOW_RESTOW) -d $(ROOT)/OS/Linux/ubuntu -t /etc ETC

arch: 
	$(STOW_RESTOW) -d $(ROOT)/OS/Linux/arch -t $(XDG_CONFIG_HOME) CONFIG
	$(STOW_RESTOW) -d $(ROOT)/OS/Linux/arch -t $(HOME) HOME
	sudo $(STOW_RESTOW) -d $(ROOT)/OS/Linux/arch -t /etc ETC

fedora:
	$(STOW_RESTOW) -d $(ROOT)/OS/Linux/fedora -t $(XDG_CONFIG_HOME) CONFIG
	$(STOW_RESTOW) -d $(ROOT)/OS/Linux/fedora -t $(HOME) HOME
	sudo $(STOW_RESTOW) -d $(ROOT)/OS/Linux/fedora -t /etc ETC

# MacOS specific configurations
Darwin:
	echo "Applying MacOS-specific configurations..."; \
	$(MAKE) macos

macos:
	$(STOW_RESTOW) -d $(ROOT)/OS/MacOS -t $(XDG_CONFIG_HOME) CONFIG
	$(STOW_RESTOW) -d $(ROOT)/OS/MacOS -t $(HOME) HOME
	sudo $(STOW_RESTOW) -d $(ROOT)/OS/MacOS -t /etc ETC

# Delete Operations
delete:
	$(STOW_DELETE) -d $(ROOT)/ -t $(XDG_CONFIG_HOME) CONFIG
	$(STOW_DELETE) -d $(ROOT)/ -t $(HOME) HOME
	sudo $(STOW_DELETE) -d $(ROOT)/ -t /etc ETC
	@if [ "$(OS)" = "Linux" ]; then \
		echo "Removing Linux specific configurations..."; \
		$(STOW_DELETE) -d $(ROOT)/OS/Linux -t $(XDG_CONFIG_HOME) CONFIG; \
		$(STOW_DELETE) -d $(ROOT)/OS/Linux -t $(HOME) HOME; \
		sudo $(STOW_DELETE) -d $(ROOT)/OS/Linux -t /etc ETC; \
		if [ "$(DISTRO)" = "Ubuntu" ]; then \
			echo "Removing Ubuntu-specific configurations..."; \
			$(STOW_DELETE) -d $(ROOT)/OS/Linux/ubuntu -t $(XDG_CONFIG_HOME) CONFIG; \
			$(STOW_DELETE) -d $(ROOT)/OS/Linux/ubuntu -t $(HOME) HOME; \
			sudo $(STOW_DELETE) -d $(ROOT)/OS/Linux/ubuntu -t /etc ETC; \
		elif [ "$(DISTRO)" = "Arch Linux" ]; then \
			echo "Removing Arch-specific configurations..."; \
			$(STOW_DELETE) -d $(ROOT)/OS/Linux/arch -t $(XDG_CONFIG_HOME) CONFIG; \
			$(STOW_DELETE) -d $(ROOT)/OS/Linux/arch -t $(HOME) HOME; \
			sudo $(STOW_DELETE) -d $(ROOT)/OS/Linux/arch -t /etc ETC; \
		elif [ "$(DISTRO)" = "Fedora Linux" ]; then \
			echo "Removing Fedora-specific configurations..."; \
			$(STOW_DELETE) -d $(ROOT)/OS/Linux/fedora -t $(XDG_CONFIG_HOME) CONFIG; \
			$(STOW_DELETE) -d $(ROOT)/OS/Linux/fedora -t $(HOME) HOME; \
			sudo $(STOW_DELETE) -d $(ROOT)/OS/Linux/fedora -t /etc ETC; \
		fi; \
	fi
	@if [ "$(OS)" = "Darwin" ]; then \
		echo "Removing MacOS specific configurations..."; \
		$(STOW_DELETE) -d $(ROOT)/OS/MacOS -t $(XDG_CONFIG_HOME) CONFIG; \
		$(STOW_DELETE) -d $(ROOT)/OS/MacOS -t $(HOME) HOME; \
		sudo $(STOW_DELETE) -d $(ROOT)/OS/MacOS -t /etc ETC; \
	fi

