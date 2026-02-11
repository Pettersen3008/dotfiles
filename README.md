# Dotfiles

Nix-first personal environment for macOS and Arch Linux.

This repo manages:
- macOS system config with `nix-darwin`
- user environment with `home-manager`
- GUI apps on macOS with `nix-homebrew`
- language/runtime tooling with `mise`
- shell/editor/tool configs under `.config/*`

This repo does **not** use GNU Stow.

## Quick Start (macOS)

```bash
git clone <YOUR_REPO_URL> ~/.dotfiles
cd ~/.dotfiles
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Open a new shell, then:

```bash
cd ~/.dotfiles/nix
nix --extra-experimental-features "nix-command flakes" \
  run nix-darwin/master#darwin-rebuild -- switch --flake .#NAME_OF_MACHINE
```

After first successful switch:

```bash
darwin-rebuild switch --flake ~/.dotfiles/nix#NAME_OF_MACHINE
```

## Documentation

- New machine setup: `docs/NEW_MACHINE.md`
- Daily operations and command reference: `docs/OPERATIONS.md`
- Troubleshooting and recovery: `docs/TROUBLESHOOTING.md`
- Secrets workflow: `docs/SECRETS.md`
- Nix tree overview: `nix/README.md`

## Common Commands

```bash
# Apply current config
darwin-rebuild switch --flake ~/.dotfiles/nix#NAME_OF_MACHINE

# Build only (safe pre-check)
nix run nix-darwin/master#darwin-rebuild -- build --flake ~/.dotfiles/nix#NAME_OF_MACHINE

# Update inputs and rebuild
just update
```

## What Is Managed

- Shell: `zsh` (modular), `starship`, `zoxide`, `fzf`, `bat`, `eza`
- Dev tools: `mise`, `ripgrep`, `fd`, `jq`, `git`, `git-lfs`
- Security tools: `gitleaks`, `sops`, `age`
- macOS apps: `nix/modules/darwin/apps.nix`

## Repository Map

- `nix/`: system and home-manager configuration
- `.config/zsh/`: split zsh modules
- `.config/git/`: git config and ignores
- `.githooks/`: local hook scripts
- `.github/workflows/`: CI checks
- `docs/`: runbooks and reference docs
- `justfile`: operational shortcuts

## Notes

- Host key `mbp` is defined in `nix/flake.nix`.
- `nix-homebrew` is enabled for macOS app casks.
- Homebrew activation cleanup is set to `none`.
