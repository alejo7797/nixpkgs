{
  pkgs,
  lib ? pkgs.lib,
  runTestOn,
  ...
}:

let
  releases = import ../../release.nix {
    configuration = {
      # Building documentation makes the test unnecessarily take a longer time:
      documentation.enable = lib.mkForce false;
      documentation.nixos.enable = lib.mkForce false;
      # including a channel forces images to be rebuilt on any changes
      system.installer.channel.enable = lib.mkForce false;
    };
  };

  lxc-image-metadata =
    releases.incusContainerMeta.${pkgs.stdenv.hostPlatform.system}
    + "/tarball/nixos-image-lxc-*-${pkgs.stdenv.hostPlatform.system}.tar.xz";
  # the incus container rootfs is in squashfs, but lxc requires tar.xz so use containerTarball
  lxc-image-rootfs =
    releases.containerTarball.${pkgs.stdenv.hostPlatform.system}
    + "/tarball/nixos-image-lxc-*-${pkgs.stdenv.hostPlatform.system}.tar.xz";

in
{
  unprivileged-container = runTestOn [ "x86_64-linux" "aarch64-linux" ] {
    imports = [ ./unprivileged-container.nix ];
    _module.args = {
      inherit
        lxc-image-metadata
        lxc-image-rootfs
        ;
    };
  };
  unprivileged-user-lxcbr0 = runTestOn [ "x86_64-linux" "aarch64-linux" ] {
    imports = [ ./unprivileged-user-lxcbr0.nix ];
    _module.args = {
      inherit
        lxc-image-metadata
        lxc-image-rootfs
        ;
    };
  };

  unprivileged-user-virbr0 = runTestOn [ "x86_64-linux" "aarch64-linux" ] {
    imports = [ ./unprivileged-user-virbr0.nix ];
    _module.args = {
      inherit
        lxc-image-metadata
        lxc-image-rootfs
        ;
    };
  };
}
