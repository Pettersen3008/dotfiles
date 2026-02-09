# Secrets (Unified macOS + Linux)

This repo uses one default secret workflow on both platforms:

- `sops` for encryption/decryption
- `age` keys for recipients
- encrypted file in repo: `secrets/npm-tokens.sops.env`

No plaintext secrets are committed.

## Runtime lookup order

In shell startup:

1. Existing environment variables
2. `~/.dotfiles/secrets/npm-tokens.sops.env` (decrypted with `sops`)
3. Optional local fallback `~/.config/secrets/npm-tokens.env` (ignored by git)

## First-time setup

```bash
cd ~/.dotfiles
./scripts/sops-init-age.sh
SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt" EDITOR="${EDITOR:-nano}" SOPS_CONFIG=.sops.yaml sops secrets/npm-tokens.sops.env
```

Put values in dotenv format:

```dotenv
NPM_TOKEN=...
NPM_NEXUM_TOKEN=...
NPM_FORTAWESOME_TOKEN=...
```

## Multi-machine strategy (recommended)

Run `./scripts/sops-init-age.sh` on each machine (macOS and Linux).  
The script keeps existing recipients and adds the current machine key, then updates encrypted file keys.

This gives:

- one encrypted file shared in git
- each machine decrypts with its own private key
- no platform-specific secret backend required

## Optional local fallback (ignored)

Create `~/.config/secrets/npm-tokens.env`:

```bash
export NPM_TOKEN='...'
export NPM_NEXUM_TOKEN='...'
export NPM_FORTAWESOME_TOKEN='...'
```

Set strict permissions:

```bash
chmod 600 ~/.config/secrets/npm-tokens.env
```
