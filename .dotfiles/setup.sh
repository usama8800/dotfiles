#!/usr/bin/env bash

set -ex

if [ ! -d "$HOME"/.dotfiles ]; then
  mkdir "$HOME"/.dotfiles
fi
pushd "$HOME"/.dotfiles || exit 1
if [ ! -d dotfiles.git ]; then
  set +e
  git clone --bare git@github.com:usama8800/dotfiles.git
  success=$?
  set -e
  if [ "$success" -ne 0 ]; then
    if [[ ! -f "$HOME/.ssh/id_ed25519.pub" ]]; then
      ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -C "usama8800@gmail.com"
    fi
    curl -F 'clbin=<-' https://qrenco.de <"$HOME/.ssh/id_ed25519.pub"
    echo "Add this to github and run again"
    exit 1
  fi
fi
if [ ! -f setup.sh ]; then
  git --git-dir=dotfiles.git/ --work-tree="$HOME" checkout
fi
git --git-dir=dotfiles.git config status.showUntrackedFiles no
git --git-dir=dotfiles.git branch --set-upstream-to origin/master
git --git-dir=dotfiles.git config remote.origin.fetch "+refs/heds/*:refs/remotes/origin/*"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tomasklaen/uosc/HEAD/installers/unix.sh)"
popd || exit 1
