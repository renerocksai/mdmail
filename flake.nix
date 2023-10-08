{
  description = "mdmail flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Used for shell.nix
    flake-compat = {
      url = github:edolstra/flake-compat;
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system; };
        appEnv = with pkgs; [
            pandoc
            xdg-utils
        ];
      in rec {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            appEnv
          ];

          buildInputs = with pkgs; [
            # we need a version of bash capable of being interactive
            # as opposed to a bash just used for building this flake 
            # in non-interactive mode
            bashInteractive 
          ];

          shellHook = ''
            # once we set SHELL to point to the interactive bash, neovim will 
            # launch the correct $SHELL in its :terminal 
            export SHELL=${pkgs.bashInteractive}/bin/bash
          '';
        };

        # For compatibility with older versions of the `nix` binary
        devShell = self.devShells.${system}.default;

        # packages
        packages.mdmail = pkgs.stdenv.mkDerivation rec {
          name = "mdmail";
          buildInputs = with pkgs; [
            appEnv
            coreutils
          ];

          builder = pkgs.writeShellScript "builder" ''
            #!/bin/sh
            export PATH="${pkgs.coreutils}/bin:$PATH"
            mkdir -p $out/bin
            cp $src/mail.template $out/
            cp $src/mail.css $out/

            cat > $out/bin/mdmail <<EOF
            #!/usr/bin/env bash
            if [ -z "\$1" ] ; then
                echo "no arg"
                exit
            fi

            md="\$1"
            html="/tmp/\$(basename \$1.html)"
            ${pkgs.pandoc.out}/bin/pandoc --embed-resources --css=$out/mail.css --template=$out/mail.template -f markdown -t html \$md -o \$html
            ${pkgs.xdg-utils.out}/bin/xdg-open \$html
            EOF
            chmod +x $out/bin/mdmail
          '';

          src = ./.;

        };
        defaultPackage = self.packages.${system}.mdmail;

    });
}
