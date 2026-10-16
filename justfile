set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

host := "mbp"
flake_dir := "./nix"
mise := env("HOME") / ".local/bin/mise"

help:
  @just --list

build h=host:
  darwin-rebuild build --flake "{{flake_dir}}#{{h}}"

switch h=host:
  sudo darwin-rebuild switch --flake "{{flake_dir}}#{{h}}"

update h=host: tools
  nix flake update --flake "{{flake_dir}}"
  darwin-rebuild build --flake "{{flake_dir}}#{{h}}"

# mise lives outside nix so it can stay on the latest release.
tools:
  test -x {{mise}} || curl -fsSL https://mise.run | sh
  {{mise}} self-update -y
  {{mise}} install -y
  {{mise}} upgrade -y

arch-home: tools
  nix run home-manager -- switch -b backup --flake "{{flake_dir}}#pettersen@arch"

hooks:
  ./scripts/install-git-hooks.sh

scan:
  gitleaks detect --source .

cleanup *args:
  ./scripts/declutter.sh {{args}}

sops-init:
  ./scripts/sops-init-age.sh

secrets-setup:
  ./scripts/sops-init-age.sh
  if command -v sops >/dev/null 2>&1; then SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops secrets/npm-tokens.sops.env; else nix shell nixpkgs#sops nixpkgs#nano -c sh -c 'SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops secrets/npm-tokens.sops.env'; fi

secrets-edit:
  if command -v sops >/dev/null 2>&1; then SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops secrets/npm-tokens.sops.env; else nix shell nixpkgs#sops nixpkgs#nano -c sh -c 'SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops secrets/npm-tokens.sops.env'; fi

sops-edit file:
  if command -v sops >/dev/null 2>&1; then SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops {{file}}; else nix shell nixpkgs#sops nixpkgs#nano -c sh -c 'SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops {{file}}'; fi
