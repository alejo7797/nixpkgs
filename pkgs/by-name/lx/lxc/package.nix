{
  lib,
  stdenv,
  fetchFromGitHub,

  bashInteractive,
  dbus,
  docbook2x,
  libapparmor,
  libcap,
  libseccomp,
  libselinux,
  linux-pam,
  meson,
  ninja,
  nixosTests,
  openssl,
  pkg-config,
  systemd,

  nix-update-script,
}:

let
  inherit (lib.strings)
    mesonBool
    mesonOption
    ;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "lxc";
  version = "7.0.0";

  outputs = [
    "out"
    "dev"
    "doc"
    "man"
  ];

  src = fetchFromGitHub {
    owner = "lxc";
    repo = "lxc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eB68l7SmVxJViGmVlVtEXVD+cRtr4WqOrA8b9ImQ89g=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    docbook2x
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    bashInteractive # some hooks use compgen
    dbus
    libapparmor
    libcap
    libseccomp
    libselinux
    linux-pam
    openssl
    systemd
  ];

  patches = [
    # FIXME: Install all tool man pages.
    ./docs.patch

    # Don't try installing files to /etc
    ./install-paths.patch

    # Hack around /etc/sysconfig
    ./sysconfdir-hack.patch

    # Fix hardcoded path to lxc-user-nic
    # This is needed to use unprivileged containers
    ./user-nic.diff
  ];

  postPatch = ''
    substituteInPlace templates/lxc-{download,local,oci}.in config/templates/{common,userns}.conf.in \
      --subst-var-by LXCTEMPLATECONFIG "/run/current-system/sw/share/lxc/config"

    substituteInPlace src/lxc/lxccontainer.c \
      --replace-fail LXCTEMPLATECONFIG "\"/run/current-system/sw/share/lxc/config\""

    substituteInPlace config/apparmor/{,abstractions/,profiles/}meson.build config/etc/meson.build \
      --subst-var out
  '';

  mesonFlags = [
    (mesonOption "sysconfdir" "/etc")
    (mesonOption "systemd-unitdir" "${placeholder "out"}/lib/systemd/system")
    (mesonBool "install-state-dirs" false)
    (mesonBool "pam-cgroup" true)
    (mesonBool "specfile" false)
    (mesonBool "tools" false)
    (mesonBool "tools-multicall" true)
  ];

  passthru = {
    tests = {
      incus-lts = nixosTests.incus-lts.container;
      lxc = nixosTests.lxc;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    homepage = "https://linuxcontainers.org/lxc/";
    changelog = "https://github.com/lxc/lxc/releases/tag/v${finalAttrs.version}";
    description = "Userspace tools for Linux Containers, a lightweight virtualization system";
    license = lib.licenses.gpl2;

    longDescription = ''
      LXC containers are often considered as something in the middle between a chroot and a
      full fledged virtual machine. The goal of LXC is to create an environment as close as
      possible to a standard Linux installation but without the need for a separate kernel.
    '';

    platforms = lib.platforms.linux;
    teams = [ lib.teams.lxc ];
  };
})
