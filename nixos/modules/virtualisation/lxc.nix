# LXC Configuration

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    mkOption
    ;

  cfg = config.virtualisation.lxc;

  settingsFormat = pkgs.formats.keyValue { };

  lxcSysconfig =
    let
      lxc = settingsFormat.generate "lxc" cfg.autostart.settings;
      lxc-net = settingsFormat.generate "lxc-net" cfg.bridge.settings;
    in
    pkgs.runCommand "sysconfig" { } ''
      mkdir -p $out
      ln -s ${lxc} $out/lxc
      ln -s ${lxc-net} $out/lxc-net
    '';
in

{
  meta = {
    teams = [ lib.teams.lxc ];
  };

  imports = [
    (lib.mkRemovedOptionModule [
      "virtualisation"
      "lxc"
      "bridgeConfig"
    ] "Use `virtualisation.lxc.bridge.settings` instead.")
  ];

  options.virtualisation.lxc = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        This enables Linux Containers (LXC), which provides tools
        for creating and managing system or application containers
        on Linux.
      '';
    };

    package = lib.mkPackageOption pkgs "lxc" { };

    unprivilegedContainers = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable support for unprivileged users to launch
        containers.

        Add users to the `lxc-users` group and make sure
        {option}`virtualisation.lxc.usernetConfig` lets them attach
        to the needed network interfaces.
      '';
    };

    autostart = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to autostart containers with `lxc.start.auto = 1`
          at boot. Look in {manpage}`lxc-autostart(1)` for the exact
          behaviour.
        '';
      };

      settings = mkOption {
        type = types.submodule {
          freeformType = settingsFormat.type;
          options = {
            # # BOOTGROUPS - What groups should start on bootup?
            # #	Comma separated list of groups.
            # #	Leading comma, trailing comma or embedded double
            # #	comma indicates when the NULL group should be run.
            # # Example (default): boot the onboot group first then the NULL group
            BOOTGROUPS = mkOption {
              type = types.str;
              default = "onboot,";
            };
            #
            # # SHUTDOWNDELAY - Wait time for a container to shut down.
            # #	Container shutdown can result in lengthy system
            # #	shutdown times.  Even 5 seconds per container can be
            # #	too long.
            SHUTDOWNDELAY = mkOption {
              type = types.ints.unsigned;
              default = 5;
            };
            #
            # # OPTIONS can be used for anything else.
            # #	If you want to boot everything then
            # #	options can be "-a" or "-a -A".
            OPTIONS = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            #
            # # STOPOPTS are stop options.  The can be used for anything else to stop.
            # #	If you want to kill containers fast, use -k
            STOPOPTS = mkOption {
              type = types.nullOr types.str;
              default = "-a -A -s";
            };
          };
          config = {
            LXC_AUTO = cfg.autostart.enable;
            USE_LXC_BRIDGE = cfg.bridge.enable;
          };
        };
        default = { };
        description = ''
          Configuration for...
        '';
      };
    };

    bridge = {
      enable = lib.mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to...
        '';
      };

      settings = lib.mkOption {
        type = types.submodule {
          freeformType = settingsFormat.type;
          options = {
            LXC_BRIDGE = mkOption {
              type = types.str;
              default = "lxcbr0";
              description = "";
            };

            LXC_DHCP_CONFILE = mkOption {
              type = types.nullOr (types.either types.str types.path);
              default = null;
              description = "";
            };

            LXC_IPV6_ENABLE = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Whether to...
              '';
            };
          };
          config = {
            USE_LXC_BRIDGE = cfg.bridge.enable;
          };
        };
        default = { };
        description = ''
          Configuration for...
        '';
      };
    };

    systemConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        System-wide LXC config. See {manpage}`lxc.system.conf(5)`.
      '';
    };

    defaultConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Default config (default.conf) for new containers, e.g. for
        network config. See {manpage}`lxc.container.conf(5)`.
      '';
    };

    usernetConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        This is the config file for managing unprivileged user network
        administration access in LXC. See {manpage}`lxc-usernet(5)`.
      '';
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    environment.pathsToLink = [ "/share/lxc" ];

    environment.etc = {
      "lxc/lxc.conf".text = cfg.systemConfig;
      "lxc/default.conf".text = cfg.defaultConfig;
      "lxc/lxc-usernet".text = cfg.usernetConfig;
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/lxc/rootfs 0755 root root -"
    ];

    security.apparmor.packages = [ cfg.package ];
    security.apparmor.policies = {
      "bin.lxc-copy".profile = ''
        #include <tunables/global>

        profile ${cfg.package}/bin/lxc-copy flags=(attach_disconnected) {
          #include <abstractions/lxc/start-container>
        }
      '';

      "bin.lxc-start".profile = ''
        #include <tunables/global>

        profile ${cfg.package}/bin/lxc-start flags=(attach_disconnected) {
          #include <abstractions/lxc/start-container>
        }
      '';

      "lxc-containers".profile = ''
        include ${cfg.package}/etc/apparmor.d/lxc-containers
      '';
    };

    # We don't need the `lxc-user` group unless unprivileged containers are enabled.
    users.groups = lib.mkIf cfg.unprivilegedContainers {
      lxc-user = { };
    };

    # `lxc-user-nic` needs suid for unprivileged containers to attach to the bridge.
    security.wrappers = lib.mkIf cfg.unprivilegedContainers {
      lxc-user-nic = {
        source = "${cfg.package}/libexec/lxc/lxc-user-nic";
        setuid = true;
        owner = "root";
        group = "lxc-user";
        permissions = "u+rx,g+rx,o-x";
      };
    };

    systemd.packages = [ cfg.package ];

    systemd.services.lxc = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      restartIfChanged = false;
      environment = {
        NIXOS_LXC_SYSCONF = lxcSysconfig;
      };
      path = [
        pkgs.coreutils
        pkgs.gnugrep
        pkgs.gnused
      ];
    };

    systemd.services.lxc-net = {
      enable = true;
      wantedBy = [ "multi-user.target" ];
      environment = {
        NIXOS_LXC_SYSCONF = lxcSysconfig;
      };
      path = [
        config.networking.firewall.package
        pkgs.iproute2
        pkgs.getent
        pkgs.dnsmasq
      ];
    };
  };
}
