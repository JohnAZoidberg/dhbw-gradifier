# DHBW Gradifier
![alt text](https://api.travis-ci.org/mariuskiessling/dhbw-gradifier.svg?branch=latest "Build status badge")

This simple go tool fetches all published grades from Dualis and sends you an email when new grades get published.

## :rocket: Running the Gradifier
1. Download the three files that are required for execution:
  - Your binary file (more precompiled binary files are available on the [release page](https://github.com/mariuskiessling/dhbw-gradifier/releases/tag/latest)):
    - [:apple: MacOS (32-Bit)](https://github.com/mariuskiessling/dhbw-gradifier/releases/download/latest/darwin_386_dhbw-gradifier)
    - [:apple: MacOS (64-Bit)](https://github.com/mariuskiessling/dhbw-gradifier/releases/download/latest/darwin_amd64_dhbw-gradifier)
    - [:penguin: Linux (32-Bit)](https://github.com/mariuskiessling/dhbw-gradifier/releases/download/latest/linux_386_dhbw-gradifier)
    - [:penguin:: Linux (64-Bit)](https://github.com/mariuskiessling/dhbw-gradifier/releases/download/latest/linux_amd64_dhbw-gradifier)
    - [:computer: Windows (32-Bit)](https://github.com/mariuskiessling/dhbw-gradifier/releases/download/latest/windows_386_dhbw-gradifier.exe)
    - [:computer: Windows (64-Bit)](https://github.com/mariuskiessling/dhbw-gradifier/releases/download/latest/windows_amd64_dhbw-gradifier.exe)

    _The binaries are not signed. You might have to explicitly allow running an unsigned piece of software._
  - The config file: [:floppy_disk: Download](https://github.com/mariuskiessling/dhbw-gradifier/releases/download/latest/config.json)
  - The mail notification template: [:floppy_disk: Download](https://github.com/mariuskiessling/dhbw-gradifier/releases/download/latest/notification.tpl)
2. Open the `config.json` in your favorite editor and enter all required information. The update interval should not be greater than 29 minutes because the lifetime of a Dualis session is 30 minutes.
3. If you are on Linux or MacOS you have to enable execution for the downloaded binary file. Run `chmod +x PLATFORM_ARCH_dhbw-gradifier`.
3. Run the binary file. You should receive an initial mail containing all grades published to date. This mail is sent after the first update interval is over.

## :mailbox: Configuring a mail server
If you don't have a personal mail server or don't want to use a public one like Gmail, you can use the one provided by the university.

When using the mail server provided by the DHBW, you have to enter the following information in your `config.json`:

```
"SMTPHost": "lehre-mail.dhbw-stuttgart.de",
"SMTPPort": 587,
"SMTPUsername": "itXXXXX",
"SMTPPassword": "XXXXXXXXXXXXX",
```

## Location of config and template
By default `dhbw-gradifier` tries to load the config from `config.json` in the directory you run it from.
You can override this by providing an alternative path using the environment variable `DHBW_GRADIFIER_CONFIG`
or by using the commandline flag `-c=config.json`.

By default the template is loaded from the `notification.tpl` which is next to
the executed binary. If there is `/etc/dhbw-gradifier/notification.tpl` that
will be used instead. Alternatively you can use the environment variable
`DHBW_GRADIFIER_TEMPLATE` to set your own template. The flag `-t` overrides
all other locations.

## Building with nix
Just install [nix](https://nixos.org/nix/download.html) and run `nix-build`.
Your binary will be at `result-bin/bin/dhbw-gradifier`.

## Using NixOS for deployment
Put the following config options in your system config or create a file
out of it and import that.

```nix
{ config, pkgs, ... }:
let
  rev = "7c68974d16342bb4f3b5d133d7159816d7b412d6";
  sha256 = "0w2j97rya2mb6qmcmznqq2r3rh28ahkp5a8rh22wc2p4pjnm4xvj";

  # Use builtins.fetchTarball instead of pkgs.fetchFromGitHub because
  # the result is listed in the `imports` which cannot contain entries
  # That are dependent on config or pkgs
  repo = builtins.fetchTarball {
    url = "https://github.com/JohnAZoidberg/dhbw-gradifier/archive/${rev}.tar.gz";
    inherit sha256;
  };
in
{
  # Make dhbw-gradifier service config available
  imports = [
    "${repo}/service.nix"
  ];

  # Install it in your PATH (if you want)
  #environment.systemPackages = [ pkg.dhbw-gradifier ];

  # Include dhbw-gradifier pkgs into nixpgks tree
  nixpkgs.overlays = [
    (self: super: {
      dhbw-gradifier = super.callPackage "${repo}/dhbw-gradifier.nix" {};
    })
  ];

  # Configure which students' grades get fetched and sent to whom
  services.dhbw-gradifier = {
    enable = true;

    students = {
      "it9876" = {
        password = "pa$sw0rd";
        # updateInterval = 25; # minutes default
        # Everything inferred from dualis credentials
        # notificationRecipient = "it1234@example.com";
        # notificationSmtp = {
        #   host = "lehre-mail.dhbw-stuttgart.de";
        #   port = 587;
        #   username = "it1234";
        #   password = "pa$sw0rd";
        # };
      };
      "it1234" = {
        password = "123";
        updateInterval = 5;
        notificationRecipient = "it1234@example.com";
        notificationSmtp = {
          host = "mail.example.com";
          port = 587;
          username = "user1234";
          password = "pa$sw0rd";
        };
      };
    };
  };
}
```
