{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.dhbw-gradifier;
in
{

  ###### interface

  options.services.dhbw-gradifier = {
    enable = mkEnableOption "polling of your DHBW grades";

    package = mkOption {
      description = "dhbw-gradifier package to use.";
      default = pkgs.dhbw-gradifier;
      defaultText = "pkgs.dhbw-gradifier";
      type = types.package;
    };

    students = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          password = mkOption {
            description = "Password for logging into dualis";
            type = types.string;
          };

          updateInterval = mkOption {
            description = "Poll every x minutes for changes";
            default = 25;
            type = types.int;
          };

          notificationRecipient = mkOption {
            description = "Send notification mail to this address";
            type = types.nullOr types.string;
            default = null;
          };

          notificationSmtp = mkOption {
            description = ''
            '';
            default = null;
            type = types.nullOr (types.submodule {
              options = {
                host = mkOption {
                  description = "Send notification mail to this address";
                  type = types.string;
                };

                port = mkOption {
                  description = "Send notification mail to this address";
                  type = types.int;
                };

                username = mkOption {
                  description = "Send notification mail to this address";
                  type = types.string;
                };

                password = mkOption {
                  description = ''
                    Use this password to log into smtp.
                    Defaults to dualis password
                  '';
                  type = types.string;
                };
              };
            });
          };
        };
      });
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    environment.etc = flip mapAttrs' cfg.students (username: student: nameValuePair
      ("dhbw-gradifier/${username}.conf")
      ({
        text = ''
          {
            "username": "${username}@lehre.dhbw-stuttgart.de",
            "password": "${student.password}",

            ${if student.notificationSmtp == null
              then ''
                "SMTPHost": "lehre-mail.dhbw-stuttgart.de",
                "SMTPPort": 587,
                "SMTPUsername": "${username}@lehre.dhbw-stuttgart.de",
                "SMTPPassword": "${student.password}",
              ''
              else ''
                "SMTPHost": "${student.notificationSmtp.host}",
                "SMTPPort": ${toString student.notificationSmtp.port},
                "SMTPUsername": "${student.notificationSmtp.username}",
                "SMTPPassword": "${student.notificationSmtp.password}",
              ''
            }

            "notificationRecipient": "${
              if student.notificationRecipient == null
              then "${username}@lehre.dhbw-stuttgart.de"
              else student.notificationRecipient
            }",

            "updateIntervalMinutes": 0
          }
        '';
      })
    );
    systemd.timers = flip mapAttrs' cfg.students (username: student: nameValuePair
      "dhbw-gradifier-${username}"
      {
        description = "Timer to poll grades for ${username}";
        enable = true;
        wantedBy = [ "timers.target" ];
        timerConfig = {
          Unit = "dhbw-gradifier@${username}.service";
          OnActiveSec = "${toString student.updateInterval}min";
          OnBootSec = "${toString student.updateInterval}min";
        };
      }
    );

    systemd.services."dhbw-gradifier@" = {
      description = "dhbw-gradifier polling service template for %I";
      after = [ "network.target" ];
      serviceConfig = {
        User = "dhbw-gradifier";
        Group = "dhbw-gradifier";
        ExecStart = "${cfg.package}/bin/dhbw-gradifier -c=/etc/dhbw-gradifier/%i.conf";
      };
    };

    users.extraUsers.dhbw-gradifier = {
      description = "User which runs dhbw-gradifier";
      group = "dhbw-gradifier";
    };

    users.extraGroups.dhbw-gradifier = {
      name = "dhbw-gradifier";
    };
  };
}
