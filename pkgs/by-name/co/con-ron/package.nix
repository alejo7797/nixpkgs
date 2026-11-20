{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage {
  pname = "con-ron";
  version = "0-unstable-2026-11-17";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "leanprover";
    repo = "con-ron";
    rev = "de06320fcdce1ee999bb7a751725e5840d54c3fe";
    hash = "sha256-hk8H93WWbedec4Jq3eOv2U3Owyf6su5GWVJ/GJuUEdg=";
  };

  cargoHash = "sha256-cxUCIOZDmZ1F2YoNQ2+C5XRUxPowGHZdVJ7ZPhnOjUc=";

  meta = {
    description = "Rust port of con-leche";
    license = lib.licenses.asl20;
    homepage = "https://github.com/leanprover/con-ron";
    maintainers = with lib.maintainers; [ alejo7797 ];
  };
}
