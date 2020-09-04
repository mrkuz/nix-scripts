#!/usr/bin/env bash

set -e

KEEP_GENERATIONS="2"

sudo nix-env --delete-generations +"$KEEP_GENERATIONS" --profile /nix/var/nix/profiles/system
sudo nix-env --delete-generations +"$KEEP_GENERATIONS" --profile /nix/var/nix/profiles/per-user/markus/home-manager
sudo nix-env --delete-generations +"$KEEP_GENERATIONS" --profile /nix/var/nix/profiles/per-user/markus/profile

sudo nix-collect-garbage
