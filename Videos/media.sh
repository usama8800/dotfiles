#!/usr/bin/env bash

# if first param is list or ls then list

# rsync --delete-excluded --delete --archive --verbose --prune-empty-dirs --human-readable --progress --partial --append \
#   --include=*/ --include-from=include.txt --exclude=* --list-only server:/mnt/hdd/Media/* Media/

args=(
  "--delete-excluded"
  "--delete"
  "--archive"
  "--verbose"
  "--prune-empty-dirs"
  "--human-readable"
  "--progress"
  "--partial"
  "--append"
  "--include=*/"
  "--include-from=include.txt"
  "--exclude=*"
)

if [ "$1" == "list" ] || [ "$1" == "ls" ]; then
  args+=("--list-only")
fi

rsync "${args[@]}" server:/mnt/hdd/Media/* Media/
