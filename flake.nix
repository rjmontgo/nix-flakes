{
  description = "A nix flake for my node versions that are cached in s3";

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
          "openssl-1.1.1w"
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

      buildNodeJs =
        {
          python ? pkgs.python310,
          openssl ? pkgs.openssl,
          enableNpm,
          version,
          sha256
        }:
        let
          nodejsbuilder = pkgs.callPackage
            "${nixpkgs}/pkgs/development/web/nodejs/nodejs.nix" {
              inherit python openssl;
            };
        in
          nodejsbuilder {
            inherit enableNpm version sha256;
          };
    in
      {
        packages.x86_64-linux.nodejs_20-9-0 = buildNodeJs {
          enableNpm = true;
          version = "20.9.0";
          sha256 = "sha256-oj2WgQq/BFVCazSdR85TEPMwlbe8BXG5zFEPSBw6RRk=";
        };

        packages.x86_64-linux.nodejs_18-19-0 = buildNodeJs {
          enableNpm = false;
          version = "18.19.0";
          sha256 = "sha256-9StBryBZapq9jtdSQYN+xDlFRoIhRIu/hBNh4gkYGbY=";
        };

        packages.x86_64-linux.nodejs_16-13-1 = buildNodeJs {
          enableNpm = true;
          version = "16.13.1";
          sha256 = "sha256-TCMAT9der3ma2Odv409T4DJ/Qz1Ky/yIM5b3LpbMY60=";
          openssl = pkgs.openssl_1_1;
        };
        
        packages.x86_64-linux.npm_9-6-7 = buildNpm {
          version = "9.6.7";
          sha256 = "sha256-mmw7kkUL42wtcWskDc4y2Rgo6Q2IIevxcbCYK5+pXVs=";
          npmDepsHash = "sha256-wRY5+lVMw2myi98VeI7raNvrltObv6z3bbBU9VcnaTo=";
        };
      };
}
