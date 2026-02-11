# Troubleshooting

Fast recovery for common Nix and shell failures.

## 1) `zsh: command not found: nix`

Cause:
- Current shell PATH does not include Nix profile paths.

Fix:

```bash
export PATH="/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/etc/profiles/per-user/$USER/bin:$HOME/.nix-profile/bin:$PATH"
hash -r
nix --version
```

## 2) `zsh: command not found: darwin-rebuild`

Cause:
- `darwin-rebuild` not in current PATH or system config not switched yet.

Fix:

```bash
cd ~/.dotfiles/nix
nix --extra-experimental-features "nix-command flakes" \
  run nix-darwin/master#darwin-rebuild -- switch --flake .#mbp
```

After first successful switch:

```bash
darwin-rebuild switch --flake ~/.dotfiles/nix#mbp
```

## 3) `zsh: command not found: eza` when running `ls`

Cause:
- `ls` alias points to `eza` and `eza` is missing from PATH.

Immediate workaround:

```bash
unalias ls l la ll lt
/bin/ls -la
```

Permanent fix:
- Recover Nix PATH and run a successful rebuild.
- Ensure `eza` remains in `nix/modules/shared/core.nix`.

## 4) `experimental Nix feature 'nix-command' is disabled`

Cause:
- Fresh/official Nix install with flakes not yet enabled for current config.

One-time bootstrap:

```bash
cd ~/.dotfiles/nix
nix --extra-experimental-features "nix-command flakes" \
  run nix-darwin/master#darwin-rebuild -- switch --flake .#mbp
```

Current repo configuration also sets:
- `nix.enable = true`
- `nix.settings.experimental-features = [ "nix-command" "flakes" ]`

File:
- `nix/modules/darwin/base.nix`

## 5) `opening a connection to remote store 'daemon' previously failed`

Cause:
- Nix daemon socket unavailable or launch daemon not running.

Check socket:

```bash
ls -l /var/run/nix-daemon.socket
```

Start daemon:

```bash
sudo launchctl kickstart -k system/org.nixos.nix-daemon || \
sudo launchctl kickstart -k system/systems.determinate.nix-daemon
```

Then retry build/switch.

## 6) Flake registry fetch warning (network issues)

Example:
- `cannot fetch global flake registry ... cannot connect to socket ...`

Notes:
- This warning can appear when daemon/socket is broken.
- Fix daemon first; then retry.

## 7) Last-resort health checks

```bash
command -v nix
command -v darwin-rebuild
command -v eza
echo "$PATH"
nix doctor || true
```

If these still fail after daemon + bootstrap switch:
- Reinstall Nix (official installer), open a new shell, rerun bootstrap switch.
