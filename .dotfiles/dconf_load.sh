#!/usr/bin/env bash

if command -v dconf &> /dev/null; then
  if [[ -f "dconf_org_nemo.ini" ]]; then
    dconf load -f /org/nemo/ < dconf_org_nemo.ini
  fi
fi
