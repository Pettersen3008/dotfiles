# Cross-platform token resolution.
# Priority: existing env var -> SOPS encrypted file -> optional local fallback file.

load_npm_tokens() {
  # Primary path: encrypted dotenv in repo (same workflow on macOS and Linux).
  if [[ -r "$HOME/.dotfiles/secrets/npm-tokens.sops.env" ]] && command -v sops >/dev/null 2>&1; then
    if [[ -z "${NPM_TOKEN:-}" || -z "${NPM_NEXUM_TOKEN:-}" || -z "${NPM_FORTAWESOME_TOKEN:-}" ]]; then
      local key_file decrypted=""
      for key_file in \
        "${SOPS_AGE_KEY_FILE:-}" \
        "$HOME/.config/sops/age/keys.txt" \
        "$HOME/Library/Application Support/sops/age/keys.txt"
      do
        [[ -n "$key_file" && -r "$key_file" ]] || continue
        decrypted="$(SOPS_AGE_KEY_FILE="$key_file" SOPS_CONFIG="$HOME/.dotfiles/.sops.yaml" sops -d "$HOME/.dotfiles/secrets/npm-tokens.sops.env" 2>/dev/null || true)"
        [[ -n "$decrypted" ]] && break
      done

      if [[ -n "$decrypted" ]]; then
        source <(printf '%s\n' "$decrypted")
        export NPM_TOKEN NPM_NEXUM_TOKEN NPM_FORTAWESOME_TOKEN
      fi
    fi
  fi

  # Optional local fallback file (chmod 600):
  # export NPM_TOKEN=...
  # export NPM_NEXUM_TOKEN=...
  # export NPM_FORTAWESOME_TOKEN=...
  if [[ -r "$HOME/.config/secrets/npm-tokens.env" ]]; then
    source "$HOME/.config/secrets/npm-tokens.env"
  fi

  # Keep npm token vars interoperable for registries that reuse one token.
  [[ -z "${NPM_TOKEN:-}" && -n "${NPM_NEXUM_TOKEN:-}" ]] && export NPM_TOKEN="$NPM_NEXUM_TOKEN"
  [[ -z "${NPM_NEXUM_TOKEN:-}" && -n "${NPM_TOKEN:-}" ]] && export NPM_NEXUM_TOKEN="$NPM_TOKEN"
}

load_npm_tokens
