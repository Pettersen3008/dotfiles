# Nix directory

This directory contains all declarative configuration used by this dotfiles repo.

## Files

- `flake.nix`
  Entry point and outputs
- `darwin-configuration.nix`
  macOS composition root
- `home.nix`
  macOS home-manager root
- `home-linux.nix`
  Linux home-manager root
- `modules/darwin/*`
  macOS-only modules
- `modules/shared/*`
  Cross-platform modules
- `scripts/declutter.sh`
  Dry-run-first cleanup utility

## Host abstraction

Darwin hosts are defined in `flake.nix` under `darwinHosts`.
Add hosts there, then build/switch by host key.

## Main commands

```bash
cd ~/.dotfiles/nix
nix run nix-darwin/master#darwin-rebuild -- build --flake .#mbp
nix run nix-darwin/master#darwin-rebuild -- switch --flake .#mbp
```

Linux shared profile:

```bash
home-manager switch --flake ~/.dotfiles/nix#pettersen@arch
```

## Documentation

Operational docs, secrets policy, and security workflow are in:
- `~/.dotfiles/README.md`
