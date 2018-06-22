let
  fetchNixpkgsChannel = { rev, sha256 } : builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs-channels/archive/${rev}.tar.gz";
      inherit sha256;
  };
in
  import (fetchNixpkgsChannel {
    rev = "5da85431fb1df4fb3ac36730b2591ccc9bdf5c21"; # Tue May 22 03:16:04 2018 +0300
    sha256 = "0pc15wh5al9dmhcj29gwqir3wzpyk2nrplibr5xjk2bdvw6sv6c1";
  }) { config = {}; }
