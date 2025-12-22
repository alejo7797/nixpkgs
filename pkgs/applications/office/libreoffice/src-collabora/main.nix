{ fetchgit, ... }:
fetchgit {
  url = "https://gerrit.libreoffice.org/core";
  tag = "cp-25.04.8-1";
  hash = "sha256-Ddof55XENNbxsho1NT+O5Qrz0bTQurx42EPICRLvfPs=";
  fetchSubmodules = false;
}
