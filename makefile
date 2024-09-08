.PHONY: all delete

all: 
	stow --verbose --dotfiles --restow dot-config -t ~/.config
	stow --verbose --dotfiles --restow home-dir -t ~/

delete:
	stow --verbose --dotfiles --delete dot-config -t ~/.config
	stow --verbose --dotfiles --delete home-dir -t ~/
