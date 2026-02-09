set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

host := "mbp"
flake_dir := "{{justfile_directory()}}/nix"

help:
  @just --list

build h=host:
  cd "{{flake_dir}}"
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  nix run nix-darwin/master#darwin-rebuild -- build --flake .#{{h}}

switch h=host:
  cd "{{flake_dir}}"
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  nix run nix-darwin/master#darwin-rebuild -- switch --flake .#{{h}}

update h=host:
  cd "{{flake_dir}}"
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  nix flake update
  nix run nix-darwin/master#darwin-rebuild -- build --flake .#{{h}}

arch-home:
  cd "{{flake_dir}}"
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  home-manager switch --flake .#pettersen@arch

hooks:
  ./scripts/install-git-hooks.sh

scan:
  gitleaks detect --source .

cleanup *args:
  ./nix/scripts/declutter.sh {{args}}

sops-init:
  ./scripts/sops-init-age.sh

secrets-setup:
  ./scripts/sops-init-age.sh
  if command -v sops >/dev/null 2>&1; then SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops secrets/npm-tokens.sops.env; else nix shell nixpkgs#sops nixpkgs#nano -c sh -c 'SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops secrets/npm-tokens.sops.env'; fi

secrets-edit:
  if command -v sops >/dev/null 2>&1; then SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops secrets/npm-tokens.sops.env; else nix shell nixpkgs#sops nixpkgs#nano -c sh -c 'SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops secrets/npm-tokens.sops.env'; fi

sops-edit file:
  if command -v sops >/dev/null 2>&1; then SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops {{file}}; else nix shell nixpkgs#sops nixpkgs#nano -c sh -c 'SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops {{file}}'; fi
