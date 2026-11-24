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

## Claude Code plugin (manual step)

`claude/` is a local Claude Code plugin marketplace (`niclas`) with the
`claude-notify` plugin: a dunst notification when a session needs you
(permission prompt, question, or finished and waiting), closed again when the
session continues. Styling comes from the `[claude-code]` rule in
`OS/Linux/CONFIG/dunst/dunstrc`.

`make` does not install it. Run once per machine, inside Claude Code:

```
/plugin marketplace add ~/.dotfiles/claude
/plugin install claude-notify@niclas
```

Claude Code records this in `~/.claude/settings.json` itself; the file is not
part of this repo. Sessions that were already running don't load the hooks,
start a new one.

Claude Code runs a cached copy (`~/.claude/plugins/cache/niclas`), so after
changing files in `claude/` (or `git pull`) update it:

```
/plugin marketplace update niclas
/plugin update claude-notify@niclas
```

Test without a real session by feeding a hook event by hand:

```bash
echo '{"session_id":"test","cwd":"/tmp","notification_type":"permission_prompt","message":"test"}' \
  | ~/.dotfiles/claude/claude-notify/claude-notify.sh show
echo '{"session_id":"test"}' | ~/.dotfiles/claude/claude-notify/claude-notify.sh close
```

Remove: `/plugin uninstall claude-notify@niclas`.

## Architecture

### install.sh

`install.sh` is the installation script that does the following steps:
1. run OS-specific installation script that installs packages to enable ansible setup
2. run ansible roles based on the seutp.yml config
3. handels directory conflicts that might occur on the running system
4. runs the makefile that uses stow to create symlinks

## TODOs

- Add Nvim Mason dependencies to be installed automatically
- Add kickoff installation for Linux
- Add cargo installtion for linux
- Add sway installation for ubuntu



