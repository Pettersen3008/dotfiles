# Dotfiles

Nix-first personal environment for macOS and Arch Linux.

This repo manages:
- macOS system config with `nix-darwin`
- user environment with `home-manager`
- GUI apps on macOS with `nix-homebrew`
- language/runtime tooling with `mise`
- shell/editor/tool configs under `.config/*`

This repo does **not** use GNU Stow.

## What this config includes

- Shell: `zsh` (modular), `starship`, `zoxide`, `fzf`, `bat`, `eza`
- Dev tooling: `mise`, `ripgrep`, `fd`, `jq`, `git`, `git-lfs`
- Security tooling: `gitleaks`, `sops`, `age`
- macOS apps: managed in `nix/modules/darwin/apps.nix`

## Repository layout

- `nix/`
  System and home-manager configuration
- `.config/zsh/`
  Split zsh modules (options, completions, functions, aliases, keys)
- `.config/git/`
  Git config and global ignore file
- `.githooks/`
  Local pre-commit guard
- `.github/workflows/`
  CI security checks
- `docs/`
  Operational playbooks (`NEW_MACHINE.md`, `SECRETS.md`)
- `justfile`
  Shortcut commands for build/switch/update/security tasks

## Prerequisites

- macOS with admin access
- Nix installed (Determinate installer recommended)
- Repo cloned to `~/.dotfiles`
- Apple Silicon host currently configured as `mbp` in `nix/flake.nix`

## First setup (macOS)

```bash
cd ~/.dotfiles/nix
nix run nix-darwin/master#darwin-rebuild -- build --flake .#mbp
nix run nix-darwin/master#darwin-rebuild -- switch --flake .#mbp
```

Then enable local git hooks:

```bash
cd ~/.dotfiles
./scripts/install-git-hooks.sh
```

Optional command shortcuts with `just`:

```bash
just build
just switch
```

## Daily operations

Re-apply config:

```bash
darwin-rebuild switch --flake ~/.dotfiles/nix#mbp
```

Safe pre-check before switching:

```bash
nix run nix-darwin/master#darwin-rebuild -- build --flake ~/.dotfiles/nix#mbp
```

Update flake inputs:

```bash
cd ~/.dotfiles/nix
nix flake update
nix run nix-darwin/master#darwin-rebuild -- build --flake .#mbp
nix run nix-darwin/master#darwin-rebuild -- switch --flake .#mbp
```

Equivalent `just` target:

```bash
just update
```

## Linux (Arch) usage

Apply shared user profile:

```bash
home-manager switch --flake ~/.dotfiles/nix#pettersen@arch
```

This applies shared modules only (no macOS app/system modules).

## Host abstraction

Hosts are defined in `nix/flake.nix` under `darwinHosts`.

- Current host: `mbp`
- Add another host by adding one entry to `darwinHosts` and rebuilding with that name:

```bash
nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.dotfiles/nix#<host>
```

## Customization map

Add/remove macOS apps:
- `nix/modules/darwin/apps.nix`

Add/remove cross-platform CLI tools:
- `nix/modules/shared/core.nix`
- `nix/modules/shared/git.nix`
- `nix/modules/shared/mise.nix`

Tune zsh behavior:
- `.config/zsh/shelloptions.zsh`
- `.config/zsh/completions.zsh`
- `.config/zsh/functions/*.zsh`
- `.config/zsh/aliases.zsh`
- `.config/zsh/keys.zsh`

`~/.dotfiles/.zshrc` is only a loader.

## Secrets model

Secrets are never committed.

Token lookup order in shell:
1. Existing env vars
2. SOPS encrypted dotenv (`~/.dotfiles/secrets/npm-tokens.sops.env`)
3. Optional local fallback file

Local fallback file path:
- `~/.config/secrets/npm-tokens.env`

Ignored secret/local paths include:
- `.config/secrets/`
- `.config/zsh/local.zsh`
- `.env*`
- `.zsh-backups/`
- `nix/result*`

Cross-platform encrypted secret workflow:

```bash
cd ~/.dotfiles
./scripts/sops-init-age.sh
SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops secrets/npm-tokens.sops.env
```

Run `./scripts/sops-init-age.sh` on each machine. It appends that machine's age recipient and updates keys, so one encrypted file works on macOS and Linux.

## Security hardening

Local scan:

```bash
gitleaks detect --source .
```

Pre-commit hook:
- `.githooks/pre-commit`

CI scan:
- `.github/workflows/security.yml`

## Recovery and rollback

If a switch causes issues, roll back to previous generation:

```bash
darwin-rebuild --list-generations
sudo darwin-rebuild switch --switch-generation <generation-number>
```

## Notes

- `nix-homebrew` is enabled for macOS app casks.
- Homebrew activation cleanup is set to `none` for safer behavior.
- Raycast extensions are generally account-synced, not fully declarative.
