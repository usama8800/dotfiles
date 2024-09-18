#!/usr/bin/env bash

set -ex

if [ ! -d "$HOME"/.dotfiles ]; then
  mkdir "$HOME"/.dotfiles
fi
pushd "$HOME"/.dotfiles || exit 1
if [ ! -d dotfiles.git ]; then
  git clone --bare git@github.com:usama8800/dotfiles.git
  git --git-dir=dotfiles.git/ --work-tree="$HOME" checkout
fi
git --git-dir=dotfiles.git config status.showUntrackedFiles no
git --git-dir=dotfiles.git branch --set-upstream-to origin/master
git --git-dir=dotfiles.git config remote.origin.fetch "+refs/heds/*:refs/remotes/origin/*"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh)"
popd || exit 1
