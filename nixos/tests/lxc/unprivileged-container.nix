{
  pkgs,
  lib,
  lxc-image-metadata,
  lxc-image-rootfs,
  ...
}:

{
  name = "lxc-container-basic";

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
        bridge.enable = true;
        systemConfig = ''
          lxc.lxcpath = /tmp/lxc
        '';
        defaultConfig = ''
          lxc.net.0.type = veth
          lxc.net.0.link = lxcbr0
          lxc.net.0.flags = up
          lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx
          lxc.idmap = u 0 1000000 65536
          lxc.idmap = g 0 1000000 65536
        '';
      };
    };

    users.users.root = {
      subUidRanges = [
        {
          startUid = 1000000;
          count = 1000000000;
        }
      ];
      subGidRanges = [
        {
          startGid = 1000000;
          count = 1000000000;
        }
      ];
    };
  };

  testScript = ''
    machine.succeed("lxc-create -t local -n test -- --metadata ${lxc-image-metadata} --fstree ${lxc-image-rootfs}")
    machine.execute("touch /tmp/console.log")
    machine.succeed("lxc-start test -o /tmp/log.txt -l DEBUG -L /tmp/console.log")
    machine.copy_from_vm("/tmp/log.txt")
    machine.copy_from_vm("/tmp/console.log")
    # machine.succeed("lxc-attach -n test -- printenv")
    machine.succeed("lxc-stop test")
  '';
}
