#!/usr/bin/env python3

import os
import re
import subprocess
import sys

if __name__ == "__main__":
    files = sys.argv[1:]
    regex = re.compile(r"duration=(\d+\.\d+)")
    total_secs = 0
    for file in files:
        probe = subprocess.run(
            [
                "ffprobe",
                "-i",
                file,
                "-show_entries",
                "format=duration",
                "-v",
                "quiet",
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        secs_str = "0"
        if probe.returncode == 0:
            match = regex.search(probe.stdout)
            if match:
                secs_str = match.group(1)
        secs = float(secs_str)
        total_secs += secs
    mins, secs = divmod(total_secs, 60)
    hours, mins = divmod(mins, 60)
    print(f"{hours:02.0f}:{mins:02.0f}:{secs:02.0f}")
