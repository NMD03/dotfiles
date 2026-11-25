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

## Git commit signing (GPG, manual step)

1. Apply the dotfiles (a real `~/.gitconfig` blocks stow, move it aside):

   ```bash
   [ -f ~/.gitconfig ] && [ ! -L ~/.gitconfig ] && mv ~/.gitconfig ~/.gitconfig.pre-dotfiles
   make
   gpg-connect-agent reloadagent /bye
   ```

2. Import the key from Bitwarden. Paste the note's **Notes** field into
   `/tmp/key.asc` and the `ownertrust` field into `/tmp/trust.txt`, then:

   ```bash
   gpg --import /tmp/key.asc               # asks for the passphrase from the note
   gpg --import-ownertrust /tmp/trust.txt
   shred -u /tmp/key.asc /tmp/trust.txt
   gpg -K 5C364F01E4081ABE0F0904B243080D701174FC32
   ```

3. Test:

   ```bash
   cd /tmp && git init signtest && cd signtest
   git commit --allow-empty -m test        # PIN window
   git log --show-signature -1             # "Good signature from NMD03 <nicjan01@gmail.com>"
   cd /tmp && rm -rf signtest
   ```

### Extend the expiry

Extend it in time, on a system that has the secret key:

```bash
gpg --quick-set-expire 5C364F01E4081ABE0F0904B243080D701174FC32 2y
gpg -K 5C364F01E4081ABE0F0904B243080D701174FC32   # new [expires: …] date
```

Then update everything that holds a copy of the key:

1. **GitHub**: Settings → SSH and GPG keys → delete the old key, add the
   output of `gpg --armor --export 5C364F01E4081ABE0F0904B243080D701174FC32`.
2. **Bitwarden**: replace the note's Notes field with
   `gpg --export-secret-keys --armor 5C364F01E4081ABE0F0904B243080D701174FC32`
   and update `expires`. The passphrase, ownertrust and revocation
   certificate stay the same.
3. **Other systems**: import the updated key there (step 2 above; importing
   over the existing key just updates its expiry).

### If the key is lost or compromised

Paste the `revocation` field into `/tmp/revoke.asc`. gpg protects it against
accidental use with a leading colon: remove the `:` in front of
`-----BEGIN PGP PUBLIC KEY BLOCK-----`, then:

```bash
gpg --import /tmp/revoke.asc
gpg --armor --export 5C364F01E4081ABE0F0904B243080D701174FC32   # upload to GitHub (replaces the old key)
```

Then create a new key and update `user.signingkey` in `HOME/dot-gitconfig`.

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



