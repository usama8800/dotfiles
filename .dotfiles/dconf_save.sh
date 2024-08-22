#!/usr/bin/env bash

if command -v dconf &> /dev/null; then
  dconf dump /org/nemo/ > dconf_org_nemo.ini
fi
