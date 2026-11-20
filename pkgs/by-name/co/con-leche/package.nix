{
  lib,
  leanPackages,
  fetchFromGitHub,
}:

leanPackages.buildLakePackage {
  pname = "con-leche";
  version = "0-unstable-2026-11-21";

  isLibrary = false;

  src = fetchFromGitHub {
    owner = "leanprover";
    repo = "con-leche";
    rev = "5ea446d5c79d23ef1f954215d094db2162f1ab6f";
    hash = "sha256-0/PFtHm2EI33Wtho58HUjrKiJJ3t5WtkUE6TaW6IMzY=";
  };

  meta = {
    description = "External lean checker with a proof of consistency";
    license = lib.licenses.asl20;
    homepage = "https://github.com/leanprover/con-leche";
    maintainers = with lib.maintainers; [ alejo7797 ];
  };
}
