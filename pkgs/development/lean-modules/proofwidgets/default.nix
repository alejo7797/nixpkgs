{
  lib,
  buildLakePackage,
  fetchFromGitHub,
  fetchNpmDeps,
  npmHooks,
  nodejs,
}:

buildLakePackage (finalAttrs: {
  pname = "lean4-proofwidgets";
  # nixpkgs-update: no auto update
  version = "0.0.121-unstable-2026-11-18";

  src = fetchFromGitHub {
    owner = "leanprover-community";
    repo = "ProofWidgets4";
    rev = "197b8bdfd8bbfea6dff6ac04170a710b231c3aaa";
    hash = "sha256-JEOWh7PsZfVP4aPEC2ReVYHOGR/Ov7wytSgvUQ5xPNg=";
  };

  leanPackageName = "proofwidgets";

  lakeHash = null;

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  npmDeps = fetchNpmDeps {
    name = "lean4-proofwidgets-npm-deps";
    src = finalAttrs.src;
    sourceRoot = "source/widget";
    hash = "sha256-z3LCBPmowLlkn5w/z72J1l8WnY60F8I7r48HMM/Lnns=";
  };
  npmRoot = "widget";

  postConfigure = ''
    local realNpm
    realNpm="$(type -P npm)"
    mkdir -p "$TMPDIR/npm-wrap"
    cat > "$TMPDIR/npm-wrap/npm" <<WRAPPER
    #!/bin/sh
    case "\$1" in ci|clean-install) exit 0 ;; esac
    exec "$realNpm" "\$@"
    WRAPPER
    chmod +x "$TMPDIR/npm-wrap/npm"
    export PATH="$TMPDIR/npm-wrap:$PATH"
  '';

  meta = {
    description = "Interactive UI framework for Lean 4 proof assistants";
    homepage = "https://github.com/leanprover-community/ProofWidgets4";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nadja-y ];
  };
})
