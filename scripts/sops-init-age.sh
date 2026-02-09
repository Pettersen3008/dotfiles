#!/usr/bin/env bash
set -euo pipefail

script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

if ! command -v age-keygen >/dev/null 2>&1 || ! command -v sops >/dev/null 2>&1; then
  if command -v nix >/dev/null 2>&1 && [[ -z "${SOPS_BOOTSTRAP_IN_NIX_SHELL:-}" ]]; then
    exec nix shell nixpkgs#age nixpkgs#sops -c env SOPS_BOOTSTRAP_IN_NIX_SHELL=1 "$script_path"
  fi
fi

if ! command -v age-keygen >/dev/null 2>&1; then
  echo "age-keygen not found. Install age (or run with nix shell)." >&2
  exit 1
fi

if ! command -v sops >/dev/null 2>&1; then
  echo "sops not found. Install sops (or run with nix shell)." >&2
  exit 1
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
config_key_dir="$HOME/.config/sops/age"
mac_key_dir="$HOME/Library/Application Support/sops/age"
mkdir -p "$config_key_dir" "$mac_key_dir" "$repo_root/secrets"

if [[ -n "${SOPS_AGE_KEY_FILE:-}" ]]; then
  key_file="$SOPS_AGE_KEY_FILE"
elif [[ -f "$mac_key_dir/keys.txt" ]]; then
  key_file="$mac_key_dir/keys.txt"
elif [[ -f "$config_key_dir/keys.txt" ]]; then
  key_file="$config_key_dir/keys.txt"
elif [[ "$(uname -s)" == "Darwin" ]]; then
  key_file="$mac_key_dir/keys.txt"
else
  key_file="$config_key_dir/keys.txt"
fi

mkdir -p "$(dirname "$key_file")"
if [[ ! -f "$key_file" ]]; then
  age-keygen -o "$key_file"
  chmod 600 "$key_file"
  echo "Created age private key: $key_file"
fi

# Keep both common key locations synced for cross-platform/default lookup behavior.
if [[ -f "$key_file" ]]; then
  copy_if_needed() {
    local src="$1"
    local dst="$2"
    [[ "$src" == "$dst" ]] && return 0
    mkdir -p "$(dirname "$dst")"
    if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
      return 0
    fi
    cp -f "$src" "$dst"
  }

  chmod 600 "$key_file"
  copy_if_needed "$key_file" "$config_key_dir/keys.txt"
  copy_if_needed "$key_file" "$mac_key_dir/keys.txt"
  chmod 600 "$config_key_dir/keys.txt" "$mac_key_dir/keys.txt"
fi

recipient="$(age-keygen -y "$key_file" | head -n1)"
if [[ -z "$recipient" ]]; then
  echo "Failed to derive age recipient from $key_file" >&2
  exit 1
fi

recipients=()

add_recipient() {
  local r="${1:-}"
  local existing
  [[ -z "$r" ]] && return 0
  for existing in "${recipients[@]:-}"; do
    [[ "$existing" == "$r" ]] && return 0
  done
  recipients+=("$r")
}

add_recipient "$recipient"

# Keep existing recipients so additional machines can decrypt the same file.
if [[ -f "$repo_root/.sops.yaml" ]]; then
  while IFS= read -r line; do
    add_recipient "$line"
  done < <(rg -o 'age1[0-9a-z]+' "$repo_root/.sops.yaml" || true)
fi

cat > "$repo_root/.sops.yaml" <<CFG
creation_rules:
  - path_regex: ^secrets/.*\\.sops\\.(env|ya?ml|json)$
    age: [$(printf '"%s",' "${recipients[@]}" | sed 's/,$//')]
CFG

if [[ ! -f "$repo_root/secrets/npm-tokens.sops.env" ]]; then
  cat > "$repo_root/secrets/npm-tokens.sops.env" <<'ENV'
NPM_TOKEN=
NPM_NEXUM_TOKEN=
NPM_FORTAWESOME_TOKEN=
ENV
  SOPS_CONFIG="$repo_root/.sops.yaml" sops --encrypt --in-place "$repo_root/secrets/npm-tokens.sops.env"
fi

SOPS_CONFIG="$repo_root/.sops.yaml" sops updatekeys --yes "$repo_root/secrets/npm-tokens.sops.env" >/dev/null 2>&1 || true

echo "SOPS initialized."
echo "- Config: $repo_root/.sops.yaml"
echo "- Encrypted file: $repo_root/secrets/npm-tokens.sops.env"
echo "- Active recipients: ${recipients[*]}"
echo "- This machine public key: $recipient"
echo "Edit with: SOPS_CONFIG=$repo_root/.sops.yaml sops $repo_root/secrets/npm-tokens.sops.env"
