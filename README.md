# Dotfiles

This repo contains the configuration for my system. The installation of software is done using Ansible. All the configuration files are managed using Stow. 

## Usage

First clone this repo to a location where you want to manage your config files from. For example:
```bash
git clone --recurse-submodules https://github.com/NMD03/dotfiles ~/.dotfiles
```
You can start a complete setup of a system including the installation of software as well as creating the symlinks for the config files using the installation script:
```bash
./install.sh
```

### Update config
To update your config files you can update them in this repo and run the makefile:
```bash
make
```
### Delete config
To delete all symlinks created by this repo you can use the makefile:
```bash
make delete
```
### Only install software
If you only want to install the software you can run the setup.yml using Ansible:
```bash
ansible-playbook --ask-become-pass setup.yml
```

## TODOs

- Add software to Ansible Roles
- Add Nvim Mason dependencies to be installed automatically
- Add new ETC folder on all levels to be able to link files to /etc
- Add packages for sway:
    - sway packages
    - waybar
    - kickoff
- Add packages to arch install:
    - keyd
    - emptty
