{
  lib,
  buildLakePackage,
  fetchFromGitHub,
}:

buildLakePackage {
  pname = "lean4-plausible";
  # nixpkgs-update: no auto update
  version = "4.37.0-rc1-unstable-2026-11-18";

  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "plausible";
    rev = "0d8633efc105d6b15b59a8103614ae0291ee8827";
    hash = "sha256-fKeBWeJZKnICjY0r+x6GB3wan3Vc7f4HfwVUI02bpaY=";
  };

  leanPackageName = "plausible";

  meta = {
    description = "Property-based testing framework for Lean 4";
    homepage = "https://github.com/leanprover-community/plausible";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nadja-y ];
  };
}
