.PHONY: all delete ubuntu arch macos

OS := $(shell uname -s)
DISTRO := $(if $(findstring Linux,$(OS)),$(shell awk -F= '$$1=="NAME" { gsub(/"/, "", $$2); print $$2 }' /etc/os-release))

all: general $(OS)

general:
	stow --verbose --dotfiles --restow -d ./ -t ~/.config CONFIG
	stow --verbose --dotfiles --restow -d ./ -t ~/ HOME

# Linux specific configurations
Linux:
	#stow --verbose --dotfiles --restow -d ./OS/Linux -t ~/.config CONFIG
	#stow --verbose --dotfiles --restow -d ./OS/Linux -t ~/ HOME
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

