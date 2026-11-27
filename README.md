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

## Claude Code plugins (manual step)

`claude/` is a local Claude Code plugin marketplace (`niclas`) with two plugins:

- `claude-notify`: a dunst notification when a session needs you
  (permission prompt, question, or finished and waiting), closed again when the
  session continues. Styling comes from the `[claude-code]` rule in
  `OS/Linux/CONFIG/dunst/dunstrc`.
- `skills`: personal skills. Add one as `claude/skills/skills/<name>/SKILL.md`
  (frontmatter `name` and `description`, then the instructions); it shows up
  as `skills:<name>`.

`make` does not install them. Run once per machine, inside Claude Code:

```
/plugin marketplace add ~/.dotfiles/claude
/plugin install claude-notify@niclas
/plugin install skills@niclas
```

Claude Code records this in `~/.claude/settings.json` itself; the file is not
part of this repo. Sessions that were already running don't load the hooks,
start a new one.

Claude Code runs a cached copy (`~/.claude/plugins/cache/niclas`), so after
changing files in `claude/` (or `git pull`) update it:

```
/plugin marketplace update niclas
/plugin update claude-notify@niclas
/plugin update skills@niclas
```

Test without a real session by feeding a hook event by hand:

```bash
echo '{"session_id":"test","cwd":"/tmp","notification_type":"permission_prompt","message":"test"}' \
  | ~/.dotfiles/claude/claude-notify/claude-notify.sh show
echo '{"session_id":"test"}' | ~/.dotfiles/claude/claude-notify/claude-notify.sh close
```

Remove: `/plugin uninstall claude-notify@niclas` (or `skills@niclas`).

## gwt (Git worktree manager, Linux)

`OS/Linux/bin/gwt` manages a repository as a bare repo with one folder per
branch. `make` links it to `~/.local/bin/gwt`. `gwt help` lists all commands.
Example with Vulniverse (the `backend/.env` and `backend/app.db` paths are
placeholders, use the project's real ones).

### 1. Set up the project (once)

```bash
cd ~/Projects
gwt init git@github.com:vulnerability-lookup/Vulniverse.git
```

```
Vulniverse/
├── .bare/      # the Git repository
├── .git        # pointer to .bare
└── main/       # worktree for the default branch
```

### 2. Shared files (once)

`add` and `checkout` fill each new worktree from `.shared/` (not in Git).
Paths below `link/` and `copy/` mirror the worktree:

- `.shared/link/<path>` is symlinked: config that is the same everywhere
  (`.env`, `.claude/settings.local.json`).
- `.shared/copy/<path>` is copied: state each branch changes on its own (a seed
  SQLite db, so one branch's migrations don't break another).

Only paths the branch's `.gitignore` ignores are filled in (others are skipped
with a warning, so they can't get committed); existing files are never replaced.

```bash
cd ~/Projects/Vulniverse
mkdir -p .shared/link/backend .shared/copy/backend

mv main/backend/.env .shared/link/backend/.env
ln -s ../../.shared/link/backend/.env main/backend/.env   # main predates .shared: link by hand

sqlite3 main/backend/app.db ".backup .shared/copy/backend/app.db"
```

Rerun the `sqlite3 ... .backup` line to refresh the snapshot. Files added to
`.shared/` later only reach new worktrees; link them into existing ones by hand.

### 3. Daily work

```bash
cd ~/Projects/Vulniverse
git fetch --all --prune                 # once, shared by all worktrees

gwt add feature/osv-support             # new branch from origin/HEAD, fills .shared files
cd "$(gwt path feature/osv-support)"
npm --prefix frontend ci                # dependencies are per worktree
claude
```

- Existing remote branch: `gwt checkout csaf`
- Branch from local main: `gwt add feature/x --from main`
- Shorter folder name: `gwt add feature/osv-support --path osv`
- Publish: `git push -u origin feature/osv-support`
- One dev server at a time: restart it from the worktree you switch to.

### 4. Overview

```bash
gwt status
```

```
BRANCH               STATUS     AHEAD  BEHIND  UPSTREAM
csaf                 Modified       2       0  origin/csaf
feature/osv-support  Clean          1       0  origin/feature/osv-support
main                 Clean          0       3  origin/main
```

Counts are as of the last `git fetch`. `gwt pull main` updates `main`
(fast-forward only).

### 5. After the PR is merged

```bash
gwt remove feature/osv-support            # refuses if there are ignored files (copied db, node_modules)
gwt remove feature/osv-support --ignored  # deletes them, still refuses on uncommitted changes
gwt delete feature/osv-support            # --force after a squash merge
git push origin --delete feature/osv-support   # if GitHub didn't already
```

Links into `.shared/link` don't block `remove`, and removing them keeps the
shared file. `--force` deletes everything, including uncommitted changes.

Don't move or rename the project folder: the worktrees' links to `.bare` are
absolute (fix with `git worktree repair`). The `.shared` links are relative and
keep working.

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



