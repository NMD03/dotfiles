.PHONY: all delete

all: 
	stow --verbose --dotfiles --restow CONFIG -t ~/.config
	stow --verbose --dotfiles --restow HOME -t ~/

delete:
	stow --verbose --dotfiles --delete CONFIG -t ~/.config
	stow --verbose --dotfiles --delete HOME -t ~/
