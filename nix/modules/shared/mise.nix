{ ... }:
{
  # Runtime versions live in mise for cross-platform parity.
  xdg.configFile."mise/config.toml".text = ''
    [tools]
    node = "lts"
    bun = "latest"
  '';
}
