{
  lib,
  leanPackages,
  fetchFromGitHub,
}:

leanPackages.buildLakePackage {
  pname = "lean4lean";
  version = "0-unstable-2026-11-20";

  isLibrary = false;

  src = fetchFromGitHub {
    owner = "digama0";
    repo = "lean4lean";
    rev = "23fd0341e823a332ce5df21a1897c8afcbf34471";
    hash = "sha256-uxhqjvkFDP+LCtczFqiiTqFQPfA1Q+V/O6p6xr3F2QI=";
  };

  leanDeps = with leanPackages; [
    batteries
  ];

  buildTargets = [ "lean4lean" ];

  meta = {
    description = "Lean 4 kernel / 'external checker' written in Lean 4";
    license = lib.licenses.asl20;
    homepage = "https://github.com/digama0/lean4lean";
    maintainers = with lib.maintainers; [ alejo7797 ];
  };
}
