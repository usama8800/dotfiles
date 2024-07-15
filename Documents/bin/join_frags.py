#!/usr/bin/python3

import os
import re
import subprocess


def main():
    frag_regex = re.compile(r"\.mp4\.part-Frag(\d+)$")
    files = [
        (f, frag_regex.search(f).groups()[0])
        for f in os.listdir(".")
        if frag_regex.search(f)
    ]
    files = sorted(files, key=lambda x: int(x[1]))
    i = 0
    min_frag = -1
    error_regex = re.compile(r"Impossible to open '(.+?)'")
    while True:
        with open("files.txt", "w") as writing_file:
            for file in files:
                (file, frag) = file
                if int(frag) <= min_frag:
                    continue
                writing_file.write(f"file {file}\n")
        print(f"{i}output.mp4")
        ffmpeg = subprocess.run(
            [
                "ffmpeg",
                "-f",
                "concat",
                "-i",
                "files.txt",
                "-c",
                "copy",
                "-y",
                f"{i}output.mp4",
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
        i += 1
        search = error_regex.search(str(ffmpeg.stderr))
        min_frag = 0
        if search:
            search = frag_regex.search(search.groups()[0])
            if search:
                min_frag = int(search.groups()[0])
        if min_frag == 0:
            print(ffmpeg.stdout)
            print("=" * 20)
            print(ffmpeg.stderr)
            break


if __name__ == "__main__":
    main()
