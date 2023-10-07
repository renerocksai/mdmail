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
        appEnv = with pkgs (ps: [
            pandoc
            xdg-utils
        ]);
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
            bashInteractive 
          ];

          script = pkgs.writeShellScript "mdmail" ''
            #!/usr/bin/env bash
            if [ -z "$1" ] ; then
                echo "no arg"
                exit
            fi

            md="$1"
            html="/tmp/$1.html"
            ${appEnv}/bin/pandoc --embed-resources --css=${out}/mail.css --template=${out}/mail.template -f markdown -t html $md -o $html
            ${appEnv}/bin/xdg-open 
          '';

          src = ./.;

          installPhase = ''
            mkdir -p $out/bin
            cp ./mail.template $out/
            cp ./mail.css $out/
            cp ${script} $out/bin/mdmail
          '';

        };
        defaultPackage = self.packages.${system}.mdmail;

        # Usage:
        #    nix build .#docker
        #    docker load < result
        #    docker run -p5000:5000 vianda:lastest
        packages.docker = pkgs.dockerTools.buildImage {
          name = "mdmail";       # give docker image a name
          tag = "latest";     # provide a tag
          created = "now";

          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            # paths = [ packages.mdmail appEnv pkgs.coreutils];
            paths = [ packages.mdmail appEnv ];
            pathsToLink = [ "/bin" "/tmp" ];
          };

          config = {
            Cmd = [ "${packages.mdmail}/bin/mdmail" ];
            WorkingDir = "/bin";
            Volumes = { 
                "/tmp" = { }; 
                };
            ExposedPorts = {
            };
          };
        };


    });
}
