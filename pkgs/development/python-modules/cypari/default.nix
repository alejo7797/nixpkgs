{
  lib,
  fetchFromGitHub,
  python,
  buildPythonPackage,
  nix-update-script,

  # build-time dependencies
  setuptools,
  cython,
  perl,

  # static libraries
  gmp,
  pari,
}:

buildPythonPackage (finalAttrs: {
  pname = "cypari";
  version = "2.5.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "3-manifolds";
    repo = "CyPari";
    tag = "${finalAttrs.version}_as_released";
    hash = "sha256-t8nuov7BZNSEd5ReIKsArtLvwh7BWs7rfaTswdypKgg=";
  };

  patches = [
    ./dynamic_libs.patch

    # https://github.com/3-manifolds/CyPari/pull/11
    ./pari_2_17.patch
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'requires = ["setuptools", "wheel", "cython==3.2.3"]' \
                     'requires = ["setuptools", "wheel", "cython"]'
  '';

  preBuild = ''
    # `autogen` looks for `gphelp` and PARI data files here
    mkdir libcache
    ln -s ${pari} libcache/pari
  '';

  build-system = [
    setuptools
    cython
  ];

  nativeBuildInputs = [
    perl
  ];

  buildInputs = [
    gmp
    pari
  ];

  pythonImportsCheck = [ "cypari" ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} -P -m cypari.test
    runHook postCheck
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "(.*)_as_released"
    ];
  };

  meta = {
    description = "Sage's PARI extension, modified to stand alone";
    homepage = "https://github.com/3-manifolds/CyPari";
    changelog = "https://github.com/3-manifolds/CyPari/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [
      noiioiu
      alejo7797
    ];
  };
})
