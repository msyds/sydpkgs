{ dolphin-emu, fetchFromGitHub }:

dolphin-emu.overrideAttrs (prev: final: {
  pname = "Dolphin-MPN";
  version = "0712d84";
  src = fetchFromGitHub {
    owner = "MarioPartyNetplay";
    repo = "Dolphin-MPN";
    rev = "0712d84c74f696791acf02df4c22e88741665da6";
    hash = "sha256-dhcLJCQzd7a0l3AVFFVxfQ95sVql5N4e63xdvl7h9uc=";
    fetchSubmodules = true;
  };
  meta.broken = true;
})
