{
  lib,
  buildLakePackage,
  fetchFromGitHub,
}:

buildLakePackage {
  pname = "lean4-LeanSearchClient";
  # nixpkgs-update: no auto update
  version = "4.37.0-rc1-unstable-2026-11-18";

  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "LeanSearchClient";
    rev = "146200e1ecbf7397e361475b5c0905adc5fe0670";
    hash = "sha256-FXlZPLGB7klYt95hu9ciX5x5l7wxGlqRgUxGqDawZqo=";
  };

  leanPackageName = "LeanSearchClient";

  meta = {
    description = "Lean 4 client for LeanSearch and Moogle proof search";
    homepage = "https://github.com/leanprover-community/LeanSearchClient";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nadja-y ];
  };
}
