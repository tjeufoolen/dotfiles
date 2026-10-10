# Dotfiles

My macOS setup, managed with [chezmoi](https://www.chezmoi.io/).

## What's in here

| Path in repo                                      | Applied to                 | Purpose                                                           |
| ------------------------------------------------- | -------------------------- | ----------------------------------------------------------------- |
| `dot_zshrc`                                       | `~/.zshrc`                 | zsh config (completions, plugins, aliases, fnm, starship, SDKMAN) |
| `dot_config/ghostty/config`                       | `~/.config/ghostty/config` | Ghostty terminal                                                  |
| `dot_config/starship.toml`                        | `~/.config/starship.toml`  | Starship prompt (Gruvbox preset)                                  |
| `dot_gitconfig`                                   | `~/.gitconfig`             | Git config (if tracked)                                           |
| `empty_dot_hushlogin`                             | `~/.hushlogin`             | Hides the "Last login" line                                       |
| `Brewfile`                                        | not copied (ignored)       | All Homebrew formulae, casks and App Store apps                   |
| `run_onchange_before_10-install-packages.sh.tmpl` | runs on apply              | Runs `brew bundle` whenever the Brewfile changes                  |
| `run_once_after_20-setup.sh`                      | runs once per machine      | SDKMAN, Node LTS, macOS `defaults`                                |

## Setting up a new Mac

### 1. Prerequisites

1. Sign in to the **App Store** (needed for `mas` apps like WireGuard).
2. Install Homebrew (its installer also installs the Xcode command line tools if they're missing):
   ```sh
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```
3. Create a new SSH key and add it to GitHub. **Do this before step 2 below**, because the dotfiles repo is cloned over SSH. The old Mac's private key is not restored; every Mac gets its own key.

   ```sh
   ssh-keygen -t ed25519 -C "<email>"
   ```

   Create `~/.ssh/config` so the key is loaded from the macOS Keychain:

   ```
   Host github.com
     AddKeysToAgent yes
     UseKeychain yes
     IdentityFile ~/.ssh/id_ed25519
   ```

   Add the key to the agent, copy the public key, and add it on GitHub (Settings → SSH and GPG keys → New SSH key):

   ```sh
   ssh-add --apple-use-keychain ~/.ssh/id_ed25519
   pbcopy < ~/.ssh/id_ed25519.pub
   ```

   Check that it works (it should greet me by username):

   ```sh
   ssh -T git@github.com
   ```

   If the old Mac is retired, remove its key from the same GitHub page.

### 2. Apply the dotfiles

```sh
brew install chezmoi
chezmoi init --apply git@github.com:tjeufoolen/dotfiles.git
```

This clones the repo over SSH, copies the config files into place, installs everything in the Brewfile, and runs the one-time setup script. If it fails with a permission error, the SSH key from step 1.3 is not set up correctly.

### 3. Restart the terminal

Quit Ghostty (Cmd+Q) and reopen it. If Nerd Font icons or the font don't show up, reboot once so macOS registers the newly installed fonts.

### 4. Manual steps (not automated)

Open a new terminal tab first, so zsh, SDKMAN and fnm are loaded.

#### Apple (System Settings)

- Spotlight → Results from System → uncheck everything except **Apps** and **Menu items**

#### Firefox

- Log in to the account and turn on sync

#### Ghostty

- The config is tracked as `~/.config/ghostty/config`. Keep only one config file (not also `config.ghostty` in `~/Library/Application Support/com.mitchellh.ghostty/`), otherwise Ghostty loads both
- Check it with `ghostty +show-config | grep -E "font-family|^theme"`

#### Git and GitHub

Git uses SSH (key created in the prerequisites), so `gh auth setup-git` is not needed.

```sh
gh auth login      # choose GitHub.com, protocol SSH, authenticate with the browser
gh auth status
```

- If the identity is not tracked, create `~/.gitconfig.local` with my name and email
- Shell completion:
  ```sh
  gh completion -s zsh > /opt/homebrew/share/zsh/site-functions/_gh
  rm -f ~/.zcompdump*
  ```

#### mas (App Store)

These are normally installed through the Brewfile. Manually:

```sh
mas install 497799835     # Xcode (mas search xcode doesn't always show it; use the ID)
mas install 1451685025    # WireGuard
```

#### SDKMAN

```sh
sdk list java | grep -- '-tem'
sdk install java <21.x.y-tem>     # copy the exact identifier from the list
sdk install java <25.x.y-tem>
sdk install maven
sdk install gradle
```

#### fnm

```sh
fnm install --lts
fnm default lts-latest
```

#### macOS

- `~/.hushlogin` is tracked by chezmoi. If it's missing: `touch ~/.hushlogin`

#### Visual Studio Code

- Log in to the account and turn on Settings Sync

#### WhatsApp

- Disable all notifications

#### WireGuard

- Import the tunnel(s) from the `.conf` file in my password manager (menu bar icon → Import tunnel(s) from file)

#### Podman

```sh
softwareupdate --install-rosetta --agree-to-license
podman machine init
podman machine start
podman completion zsh > /opt/homebrew/share/zsh/site-functions/_podman
rm -f ~/.zcompdump*
```

In Podman Desktop → Settings:

- Docker compatibility → enable
- Docker compatibility → install the compose extension
- Disable "start Podman on system start"

#### IntelliJ

- Disable telemetry
- Settings → Backup & sync → log in and turn it on
- Settings → Backup & sync → sync across all products

## Daily workflow

```sh
chezmoi edit ~/.zshrc        # edit the source file
chezmoi diff                 # preview changes
chezmoi apply -v             # write changes to $HOME
chezmoi re-add               # pull manual edits of tracked files back into the repo
chezmoi cd                   # go to the repo, then commit and push
```

### Adding a Homebrew package

```sh
brew install <name>
brew bundle dump --force --file="$(chezmoi source-path)/Brewfile"
git -C "$(chezmoi source-path)" diff Brewfile    # check before committing
```

### Adding a new config file

```sh
chezmoi add ~/.config/<tool>/<file>
```

## Not stored in this repo

- SSH keys (a new key is created per Mac, see prerequisites), API tokens, `.env` files
- WireGuard `.conf` files (contain private keys)
- `~/.zsh_history`
- `~/.config/gh/hosts.yml` and other per-machine login state

Machine-specific or secret shell settings go in `~/.zshrc.local`, which `.zshrc` sources if it exists.
