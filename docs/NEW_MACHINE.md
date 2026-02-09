# New Machine Checklist

Use this when setting up a fresh macOS or Arch machine.

## 1) Clone dotfiles

```bash
git clone <YOUR_REPO_URL> ~/.dotfiles
cd ~/.dotfiles
```

## 2) Install Nix

macOS (recommended installer):

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

Open a new shell, then verify:

```bash
nix --version
```

## 3) Build before switching

```bash
cd ~/.dotfiles/nix
nix run nix-darwin/master#darwin-rebuild -- build --flake .#mbp
```

## 4) Switch (macOS)

```bash
nix run nix-darwin/master#darwin-rebuild -- switch --flake .#mbp
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
