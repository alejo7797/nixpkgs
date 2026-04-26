{
  lib,
  lxc-image-metadata,
  lxc-image-rootfs,
  ...
}:

{
  name = "lxc-unprivileged-user-virbr0";

  meta = {
    maintainers = lib.teams.lxc.members;
  };

  nodes.machine = {
    virtualisation = {
      diskSize = 6144;
      cores = 2;
      memorySize = 512;
      writableStore = true;

      lxc = {
        enable = true;
        unprivilegedContainers = true;
        systemConfig = ''
          lxc.lxcpath = /tmp/lxc
        '';
        defaultConfig = ''
          lxc.net.0.type = veth
          lxc.net.0.link = virbr0
          lxc.net.0.flags = up
          lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx
          lxc.idmap = u 0 100000 65536
          lxc.idmap = g 0 100000 65536
        '';
        # Permit user alice to connect to bridge
        usernetConfig = ''
          @lxc-user veth virbr0 10
        '';
        bridge.enable = false;
      };

      libvirtd.enable = true;
    };

    # Create user for test
    users.users.alice = {
      isNormalUser = true;
      password = "test";
      description = "LXC unprivileged user with access to virbr0";
      extraGroups = [ "lxc-user" ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
    };

    users.users.bob = {
      isNormalUser = true;
      password = "test";
      description = "LXC unprivileged user without access to virbr0";
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
    };
  };

  testScript = ''
    machine.wait_for_unit("libvirtd.service")

    # Copy config files for alice
    machine.execute("su -- alice -c 'mkdir -p ~/.config/lxc'")
    machine.execute("su -- alice -c 'cp /etc/lxc/default.conf ~/.config/lxc/'")
    machine.execute("su -- alice -c 'cp /etc/lxc/lxc.conf ~/.config/lxc/'")

    machine.succeed("su -- alice -c 'lxc-create -t local -n test -- --metadata ${lxc-image-metadata} --fstree ${lxc-image-rootfs}'")
    machine.execute("su -- alice -c 'lxc-start test -o /tmp/alice.log -l DEBUG'")
    machine.copy_from_vm("/tmp/alice.log", "alice.log")
    # machine.succeed("su -- alice -c 'lxc-stop test'")
    #
    # # Copy config files for bob
    # machine.execute("su -- bob -c 'mkdir -p ~/.config/lxc'")
    # machine.execute("su -- bob -c 'cp /etc/lxc/default.conf ~/.config/lxc/'")
    # machine.execute("su -- bob -c 'cp /etc/lxc/lxc.conf ~/.config/lxc/'")
    #
    # machine.fail("su -- bob -c 'lxc-start test'")
  '';
}
