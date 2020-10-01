#!/usr/bin/env bash

set -e

function ask() {
  while true; do
    read -p "$1 [y/n/a]? " yn
    case $yn in
      [Yy]*) return 0;;
      [Nn]*) return 1;;
      [Aa]*) echo "Aborted"; exit 1;;
      *) echo "Invalid answer";;
    esac
  done
}

BRANCH="nixos-unstable-small"
REMOTE="origin"

cd /nix/nixpkgs

sudo git fetch $REMOTE
if git diff $BRANCH $REMOTE/$BRANCH --quiet --exit-code; then
  echo "Nothing to do";
  exit 0;
fi

git diff $BRANCH $REMOTE/$BRANCH --stat
if ask "Show details"; then
  git diff $BRANCH $REMOTE/$BRANCH -p
fi

if ! git diff --quiet --exit-code; then
  if ask "Local changes detected. Stash"; then
    sudo git stash
  fi
elif ! git diff --cached --quiet --exit-code; then
  if ask "Local changes detected. Stash"; then
    sudo git stash
  fi
fi

current_branch="$(git symbolic-ref --short HEAD 2>/dev/null)"
if [[ $current_branch != "$BRANCH" ]]; then
  sudo git checkout "$BRANCH"
fi

if ! ask "Proceed?"; then
  exit 0;
fi

sudo git pull

if git rev-parse stash &>/dev/null; then
  if ask "Pop stash"; then
    sudo git stash pop
  fi
fi

sudo -i nixos-rebuild switch
sudo nix-channel --update home-manager
home-manager switch

$HOME/Scripts/clean-up.sh
