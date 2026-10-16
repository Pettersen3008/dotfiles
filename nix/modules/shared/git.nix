{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    git-lfs
  ];

  # Shared git config lives in .config/git; only the 1Password signer path differs per OS.
  home.file.".gitconfig".text = ''
    [gpg "ssh"]
    	program = ${if pkgs.stdenv.hostPlatform.isDarwin
        then "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
        else "/opt/1Password/op-ssh-sign"}
  '';
}
