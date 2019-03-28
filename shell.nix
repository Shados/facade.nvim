{ nixos ? import ~/nixpkgs/nixos {
    configuration = { ... }: {
      imports = [ /etc/nixos/modules/lib ];
      nixpkgs.overlays = [
        (let
        in import /etc/nixos/modules/bespoke/pkgs/luaPackages/overlay.nix)
      ];
    };
  },
  pkgs ? nixos.pkgs
}:
let
  lp = pkgs.luajitPackages;
  localMoonscript = lp.moonscript.overrideAttrs (oldAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "Shados"; repo = "moonscript";
      rev = "596f6fb498f120ba1ba79ea43f95d73870b43a77";
      sha256 = "05kpl9l1311lgjrfghnqnh6m3zkwp09gww056bf30fbvhlfc8iyw";
    };
  });
in

pkgs.mkShell {
  buildInputs = with lp; [
    localMoonscript
    linotify
    lua moonpick
    lua-repl moor

    busted
  ];
  shellHook = ''
    export LUA_PATH="$(pwd)/lua/?.lua;''${LUA_PATH}"
  '';
}
