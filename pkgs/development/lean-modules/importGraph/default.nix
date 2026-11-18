{
  lib,
  buildLakePackage,
  fetchFromGitHub,
  Cli,
}:

buildLakePackage {
  pname = "lean4-importGraph";
  # nixpkgs-update: no auto update
  version = "4.37.0-rc1-unstable-2026-11-18";

  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "import-graph";
    rev = "cf947504529b8e2ee114e852133d13e4ac923e9b";
    hash = "sha256-KyUka4yBhmbCAWIr01kcccZhNaF2AEKKrWg9oRDC2D0=";
  };

  leanPackageName = "importGraph";
  leanDeps = [ Cli ];

  meta = {
    description = "Tools to analyse and visualise Lean 4 import structures";
    homepage = "https://github.com/leanprover-community/import-graph";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nadja-y ];
  };
}
