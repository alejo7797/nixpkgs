{
  lib,
  buildLakePackage,
  fetchFromGitHub,
}:

buildLakePackage {
  pname = "lean4-batteries";
  # nixpkgs-update: no auto update
  version = "4.37.0-rc1-unstable-2026-11-18";

  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "batteries";
    rev = "87486d547af639cb39c01f0d2f8025aa47d7dde1";
    hash = "sha256-fUwJAidSPZ/NRy15674BgT+RZAv7iBCm3yiIFRkVWZg=";
  };

  leanPackageName = "batteries";

  # Pre-build static library for downstream executables.
  # TODO: upstream this to batteries
  postPatch = ''
    substituteInPlace lakefile.toml \
      --replace-fail '[[lean_lib]]
    name = "Batteries"' '[[lean_lib]]
    name = "Batteries"
    defaultFacets = ["static"]'
  '';

  meta = {
    description = "The batteries-included extended library for Lean 4";
    homepage = "https://github.com/leanprover-community/batteries";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nadja-y ];
  };
}
