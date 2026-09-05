
{
  description = "NixOS configuration with osu!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    areofyl-fetch.url = "github:areofyl/fetch";

    spotatui = {
      url = "github:LargeModGames/spotatui";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    osu-nixello.url = "github:confucius40/osu-nixello";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };

      osu = inputs.osu-nixello.packages.${system}.osu;
      wineOsu = inputs.osu-nixello.packages.${system}.wineOsu;
    in {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit inputs wineOsu osu;
        };

        modules = [
          ./configuration.nix
        ];
      };

      packages.${system} = {
        inherit wineOsu osu;
        default = osu;
      };

      apps.${system}.default = {
        type = "app";
        program = "${osu}/bin/osu";
      };
    };
}

