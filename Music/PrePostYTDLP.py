#!/usr/bin/python3

import os

# Fix remove extra files and fix archive file
playlists = os.listdir('.')
for playlist in playlists:
  if os.path.isdir(playlist):
    files = os.listdir(playlist)
    metadata = None
    extra_archive = None
    if '.metadata' in files:
      with open(playlist + '/.metadata', 'r') as f:
        metadata = list(map(lambda x: x.strip(), f.readlines()))
    else:
      continue
    if '.archive' in files:
      with open(playlist + '/.archive', 'r') as f:
        extra_archive = list(map(lambda x: x.strip(), f.readlines()))
    else:
      continue

    for file in files:
      if file[0] == '.':
        continue
      id = file.split('- ')[-1].split('.')[0].strip()
      if id not in metadata:
        print('Deleting ' + playlist + '/' + file)
        os.remove(playlist + '/' + file)
      if 'youtube '+id in extra_archive:
        extra_archive.remove('youtube '+id)

    if len(extra_archive):
      # remove items in extra archive
      archive = None
      with open(playlist + '/.archive', 'r') as f:
        archive = list(filter(lambda x: x.strip() not in extra_archive, f.readlines()))
      with open(playlist + '/.archive', 'w') as f:
        f.write('\n'.join(archive))
