# Operations Guide

Day-to-day commands for this dotfiles setup.

## Prerequisites

- macOS host key exists in `nix/flake.nix` (current: `mbp`)
- Nix installed and daemon running
- Repo cloned to `~/.dotfiles`

## Daily Commands

Apply configuration:

```bash
darwin-rebuild switch --flake ~/.dotfiles/nix#mbp
```

Build only (pre-check):

```bash
nix run nix-darwin/master#darwin-rebuild -- build --flake ~/.dotfiles/nix#mbp
```

Update flake inputs and rebuild:

```bash
just update
```

## Using `just` Shortcuts

From repo root:

```bash
just help
just build
just switch
just update
just hooks
just scan
```

## Linux Shared Profile (Arch)

```bash
cd ~/.dotfiles/nix
home-manager switch --flake .#pettersen@arch
```

## Rollback

List generations:

```bash
darwin-rebuild --list-generations
```

Switch to a previous generation:

```bash
sudo darwin-rebuild switch --switch-generation <generation-number>
```

## Secrets Operations

Initialize key and rekey encrypted secrets:

```bash
cd ~/.dotfiles
./scripts/sops-init-age.sh
```

Edit encrypted npm token file:

```bash
cd ~/.dotfiles
SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" \
  EDITOR="${EDITOR:-nano}" \
  SOPS_CONFIG=.sops.yaml \
  sops secrets/npm-tokens.sops.env
```
