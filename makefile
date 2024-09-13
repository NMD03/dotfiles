#.PHONY: all delete ubuntu arch macos
#
#OS := $(shell uname -s)
#DISTRO := $(if $(findstring Linux,$(OS)),$(shell awk -F= '$$1=="NAME" { gsub(/"/, "", $$2); print $$2 }' /etc/os-release))
#
#all: general $(OS)
#
## General Operations
#general:
#	stow --verbose --dotfiles --restow CONFIG -t ~/.config
#	stow --verbose --dotfiles --restow HOME -t ~/
#
## Linux specific
#Linux:
#	stow --verbose --dotfiles --restow ./OS/Linux/CONFIG -t ~/.config/ 
#	stow --verbose --dotfiles --restow ./OS/Linux/HOME -t ~/
#	@if [ "$(DISTRO)" = "Ubuntu" ]; then \
#		echo "Applying Ubuntu-specific configurations..."; \
#		$(MAKE) ubuntu; \
#	elif [ "$(DISTRO)" = "Arch Linux" ]; then \
#		echo "Applying Arch-specific configurations..."; \
#		$(MAKE) arch; \
#	fi
#
#ubuntu:
#	stow --verbose --dotfiles --restow ./OS/Linux/ubuntu/CONFIG -t ~/.config/ 
#	stow --verbose --dotfiles --restow ./OS/Linux/ubuntu/HOME -t ~/
#
#arch: 
#	stow --verbose --dotfiles --restow ./OS/Linux/arch/CONFIG -t ~/.config/ 
#	stow --verbose --dotfiles --restow ./OS/Linux/arch/HOME -t ~/
#
## MacOS specific
#Darwin:
#	echo "Applying MacOS-specific configurations..."; \
#	$(MAKE) macos
#
#macos:
#	stow --verbose --dotfiles --restow ./OS/MacOS/CONFIG -t ~/.config
#	stow --verbose --dotfiles --restow ./OS/MacOS/HOME -t ~/
#
#
## Delete Operations
#delete:
#	stow --verbose --dotfiles --delete CONFIG -t ~/.config
#	stow --verbose --dotfiles --delete HOME -t ~/
#	@if [ "$(OS)" = "Linux" ]; then \
#		echo "Removing Linux specific configurations..."; \
#		stow --verbose --dotfiles --delete ./OS/Linux/CONFIG -t ~/.config; \
#		stow --verbose --dotfiles --delete ./OS/Linux/HOME -t ~/; \
#		if [ "$(DISTRO)" = "Ubuntu" ]; then \
#			echo "Removing Ubuntu-specific configurations..."; \
#			stow --verbose --dotfiles --delete ./OS/Linux/ubuntu/CONFIG -t ~/.config; \
#			stow --verbose --dotfiles --delete ./OS/Linux/ubuntu/HOME -t ~/; \
#		elif [ "$(DISTRO)" = "Arch Linux" ]; then \
#			echo "Removing Arch-specific configurations..."; \
#			stow --verbose --dotfiles --delete ./OS/Linux/arch/CONFIG -t ~/.config; \
#			stow --verbose --dotfiles --delete ./OS/Linux/arch/HOME -t ~/; \
#		fi; \
#	fi
#	@if [ "$(OS)" = "Darwin" ]; then \
#		echo "Removing MacOS specific configurations..."; \
#		stow --verbose --dotfiles --delete ./OS/MacOS/CONFIG -t ~/.config; \
#		stow --verbose --dotfiles --delete ./OS/MacOS/HOME -t ~/; \
#	fi

.PHONY: all delete ubuntu arch macos

OS := $(shell uname -s)
DISTRO := $(if $(findstring Linux,$(OS)),$(shell awk -F= '$$1=="NAME" { gsub(/"/, "", $$2); print $$2 }' /etc/os-release))

all: general $(OS)

general:
	stow --verbose --dotfiles --restow -d ./ -t ~/.config CONFIG
	stow --verbose --dotfiles --restow -d ./ -t ~/ HOME

# Linux specific configurations
Linux:
	stow --verbose --dotfiles --restow -d ./OS/Linux -t ~/.config CONFIG
	stow --verbose --dotfiles --restow -d ./OS/Linux -t ~/ HOME
	@if [ "$(DISTRO)" = "Ubuntu" ]; then \
		echo "Applying Ubuntu-specific configurations..."; \
		$(MAKE) ubuntu; \
	elif [ "$(DISTRO)" = "Arch Linux" ]; then \
		echo "Applying Arch-specific configurations..."; \
		$(MAKE) arch; \
	fi

ubuntu:
	stow --verbose --dotfiles --restow -d ./OS/Linux/ubuntu -t ~/.config CONFIG
	stow --verbose --dotfiles --restow -d ./OS/Linux/ubuntu -t ~/ HOME

arch: 
	stow --verbose --dotfiles --restow -d ./OS/Linux/arch -t ~/.config CONFIG
	stow --verbose --dotfiles --restow -d ./OS/Linux/arch -t ~/ HOME

# MacOS specific configurations
Darwin:
	echo "Applying MacOS-specific configurations..."; \
	$(MAKE) macos

macos:
	stow --verbose --dotfiles --restow -d ./OS/MacOS -t ~/.config CONFIG
	stow --verbose --dotfiles --restow -d ./OS/MacOS -t ~/ HOME

# Delete Operations
delete:
	stow --verbose --dotfiles --delete -d ./ -t ~/.config CONFIG
	stow --verbose --dotfiles --delete -d ./ -t ~/ HOME
	@if [ "$(OS)" = "Linux" ]; then \
		echo "Removing Linux specific configurations..."; \
		stow --verbose --dotfiles --delete -d ./OS/Linux -t ~/.config CONFIG; \
		stow --verbose --dotfiles --delete -d ./OS/Linux -t ~/ HOME; \
		if [ "$(DISTRO)" = "Ubuntu" ]; then \
			echo "Removing Ubuntu-specific configurations..."; \
			stow --verbose --dotfiles --delete -d ./OS/Linux/ubuntu -t ~/.config CONFIG; \
			stow --verbose --dotfiles --delete -d ./OS/Linux/ubuntu -t ~/ HOME; \
		elif [ "$(DISTRO)" = "Arch Linux" ]; then \
			echo "Removing Arch-specific configurations..."; \
			stow --verbose --dotfiles --delete -d ./OS/Linux/arch -t ~/.config CONFIG; \
			stow --verbose --dotfiles --delete -d ./OS/Linux/arch -t ~/ HOME; \
		fi; \
	fi
	@if [ "$(OS)" = "Darwin" ]; then \
		echo "Removing MacOS specific configurations..."; \
		stow --verbose --dotfiles --delete -d ./OS/MacOS -t ~/.config CONFIG; \
		stow --verbose --dotfiles --delete -d ./OS/MacOS -t ~/ HOME; \
	fi

