#!/usr/bin/env bash

git --git-dir="$HOME"/.dotfiles/dotfiles.git/ config status.showUntrackedFiles no
git --git-dir="$HOME"/.dotfiles/dotfiles.git/ config remote.origin.fetch "+refs/heds/*:refs/remotes/origin/*"
