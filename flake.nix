{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        # needed to allow nix to install deprecated
        # versions of nodejs
        config.permittedInsecurePackages = [
          "nodejs-16.13.1"
          "nodejs-12.20.1"
          "python-2.7.18.7"
        ];
      };

      buildNpm = { version, sha256, npmDepsHash }: pkgs.buildNpmPackage rec {
        pname = "npm";
        inherit version;
        inherit npmDepsHash;
        dontNpmBuild = true; # we are making npm itself so don't run the build steps
        src = fetchTarball {
          url = "https://github.com/npm/cli/archive/refs/tags/v${version}.tar.gz";
          inherit sha256;
        };
      };

      buildNodeJs = { python ? pkgs.python310, enableNpm, version, sha256 }:
        let
          nodejsbuilder = pkgs.callPackage
            "${nixpkgs}/pkgs/development/web/nodejs/nodejs.nix" {
              inherit python;
            };
        in
          nodejsbuilder {
            inherit enableNpm version sha256;
          };
    in
      {
        #api-v1 doesn't specify a node version
        # web-react
        packages.x86_64-linux.nodejs_20-9-0 = buildNodeJs {
          enableNpm = true;
          version = "20.9.0";
          sha256 = "sha256-oj2WgQq/BFVCazSdR85TEPMwlbe8BXG5zFEPSBw6RRk=";
        };

        #api-v2
        packages.x86_64-linux.nodejs_18-19-0 = buildNodeJs {
          enableNpm = false;
          version = "18.19.0";
          sha256 = "sha256-9StBryBZapq9jtdSQYN+xDlFRoIhRIu/hBNh4gkYGbY=";
        };

        #web-angular
        packages.x86_64-linux.nodejs_16-13-1 = buildNodeJs {
          enableNpm = true;
          version = "16.13.1";
          sha256 = "sha256-TCMAT9der3ma2Odv409T4DJ/Qz1Ky/yIM5b3LpbMY60=";
        };
        
        #api-v2
        packages.x86_64-linux.npm_9-6-7 = buildNpm {
          version = "9.6.7";
          sha256 = "sha256-mmw7kkUL42wtcWskDc4y2Rgo6Q2IIevxcbCYK5+pXVs=";
          npmDepsHash = "sha256-wRY5+lVMw2myi98VeI7raNvrltObv6z3bbBU9VcnaTo=";
        };

        # devops-db
        packages.x86_64-linux.nodejs_12-20-1 = buildNodeJs {
          enableNpm = true;
          version = "12.20.1";
          sha256 = "sha256-4A7uMl1wWyv6mSm30GHrIxVALX6FSJRerJhwv4QyGFM=";
          python = pkgs.python2; # python2 needed to build legacy node
        };
      };
}
