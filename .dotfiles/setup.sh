#!/usr/bin/env bash

git --git-dir="$HOME"/.dotfiles/dotfiles.git/ config status.showUntrackedFiles no
git --git-dir="$HOME"/.dotfiles/dotfiles.git/ config remote.origin.fetch "+refs/heds/*:refs/remotes/origin/*"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh)"
