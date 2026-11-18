{
  lib,
  buildLakePackage,
  fetchFromGitHub,
  batteries,
}:

buildLakePackage {
  pname = "lean4-aesop";
  # nixpkgs-update: no auto update
  version = "4.37.0-rc1-unstable-2026-11-18";

  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "aesop";
    rev = "637fdbb8689a3387a82568b07355231f892144d7";
    hash = "sha256-YXrdUVW1UOJS2xctYElGFwQHSyTND85GRmeR4Lrgv/E=";
  };

  leanPackageName = "aesop";
  leanDeps = [ batteries ];

  meta = {
    description = "White-box automation for Lean 4";
    homepage = "https://github.com/leanprover-community/aesop";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nadja-y ];
  };
}
