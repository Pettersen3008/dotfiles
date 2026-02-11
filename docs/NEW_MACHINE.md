# New Machine Checklist

Use this when setting up a fresh macOS or Arch machine.

Related docs:
- `docs/OPERATIONS.md`
- `docs/TROUBLESHOOTING.md`
- `docs/SECRETS.md`

## 1) Clone dotfiles

```bash
git clone <YOUR_REPO_URL> ~/.dotfiles
cd ~/.dotfiles
```

## 2) Install Nix

macOS (official installer, daemon mode):

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Open a new shell, then verify:

```bash
nix --version
```

## 3) Build before switching

```bash
cd ~/.dotfiles/nix
nix --extra-experimental-features "nix-command flakes" \
  run nix-darwin/master#darwin-rebuild -- build --flake .#NAME_OF_MACHINE
```

## 4) Switch (macOS)

```bash
nix --extra-experimental-features "nix-command flakes" \
  run nix-darwin/master#darwin-rebuild -- switch --flake .#NAME_OF_MACHINE
```

After first successful switch, use:

```bash
darwin-rebuild switch --flake ~/.dotfiles/nix#NAME_OF_MACHINE
```

## 5) Enable hooks and security scan

```bash
cd ~/.dotfiles
./scripts/install-git-hooks.sh
gitleaks detect --source .
```

## 6) Bootstrap secrets

See `docs/SECRETS.md`.

## 7) Validate shell setup

```bash
zsh -i -c 'type cd; alias ll cleanup; echo ${NPM_TOKEN:+NPM_TOKEN_OK}'
```

## 8) Setup encrypted secrets (same on macOS and Linux)

```bash
cd ~/.dotfiles
./scripts/sops-init-age.sh
SOPS_CONFIG=.sops.yaml sops secrets/npm-tokens.sops.env
```

## 9) Linux (Arch) user profile

```bash
cd ~/.dotfiles/nix
home-manager switch --flake .#pettersen@arch
```
