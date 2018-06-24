{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "dhbw-gradifier${version}";
  version = "096ea51";

  goPackagePath = "github.com/mariuskiessling/dhbw-gradifier";

  src = ./..;
  #src = fetchFromGitHub {
  #  owner  = "mariuskiessling";
  #  repo   = "dhbw-gradifier";
  #  rev    = "${version}";
  #  sha256 = "0q55zlgn0zsjjx7psdh7wy4gv88bfnhbckbmz70d6wyanzwhjxnw";
  #};

  postInstall = ''
    cp $src/notification.tpl $bin/bin
  '';

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    #description = "A fast and modern static website engine.";
    #homepage = https://gohugo.io;
    #license = licenses.asl20;
    maintainers = with maintainers; [ johnazoidberg ];
  };
}
