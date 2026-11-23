{
  lib,
  rustPlatform,
  fetchFromGitHub,
  versionCheckHook,
  pkg-config,
  zstd,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "leangz";
  # nixpkgs-update: no auto update
  version = "0.1.22-pre1"; # Should match LEANTAR_VERSION in leanprover/lean4/CMakeLists.txt

  src = fetchFromGitHub {
    owner = "nomeata";
    repo = "leangz";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BR49v/hPbC2vNqDOLw/MJ/rnTB35FzoCjLjymm0eGp4=";
  };

  cargoHash = "sha256-axSsZ1T1VNd7liTeVIYj2DICOo49CDV5821vcXqmw0Y=";

  __structuredAttrs = true;

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ zstd ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = false;

  meta = {
    description = "Lean 4 .olean file (de)compressor";
    homepage = "https://github.com/digama0/leangz";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ niklashh ];
    mainProgram = "leantar";
  };
})
