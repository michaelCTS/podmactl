{ pkgs ? (import <nixpkgs> { }), }:
pkgs.stdenv.mkDerivation {
  name = "podmactl";
  src = ./.;

  buildInputs = [ pkgs.python311 ];
  nativeBuildInputs = with pkgs; [ (python311.withPackages (ps: with ps; [ mypy ])) nixfmt ruff ];
  doCheck = true;
  checkPhase = ''
    runHook preCheck
    (
        export RUFF_NO_CACHE=true
        set -ex
        cd $src
        nixfmt --width=100 --check *.nix

        ruff check .
        ruff format --check .
        mypy .
        python -m unittest

    )
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp podmactl.py $out/bin/podmactl
    chmod +x $out/bin/podmactl

    runHook postInstall
  '';
}
