#!/usr/bin/python3

import glob
import os
import re
import subprocess
import sys


def move(from_path, to_path):
    if os.path.exists(to_path):
        os.replace(from_path, to_path)
    else:
        os.rename(from_path, to_path)


def join_frags():
    if not os.path.exists("corrupted"):
        os.makedirs("corrupted")
    frag_regex = re.compile(r"\.mp4\.part-Frag(\d+)$")
    files = [
        (f, frag_regex.search(f).groups()[0])
        for f in os.listdir(".")
        if frag_regex.search(f)
    ]
    files = sorted(files, key=lambda x: int(x[1]))
    i = 0
    min_frag = 0
    error_regex = re.compile(r"Impossible to open '(.+?)'")
    while True:
        with open("files.txt", "w") as writing_file:
            for file in files:
                (file, frag) = file
                if int(frag) < min_frag:
                    continue
                writing_file.write(f"file {file}\n")
        print(f"{i}output.mp4 ({min_frag})")
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
            move(search.groups()[0], f"corrupted/{search.groups()[0]}")
            search = frag_regex.search(search.groups()[0])
            if search:
                min_frag = int(search.groups()[0]) + 1
        if min_frag == 0:
            print(ffmpeg.stdout)
            print("=" * 20)
            print(ffmpeg.stderr)
            break


def split_video(file, output):
    if not os.path.exists(file):
        raise ValueError(f"File not found: {file}")
    subprocess.run(
        [
            "ffmpeg",
            "-i",
            file,
            "-c",
            "copy",
            "-f",
            "segment",
            "-segment_time",
            "3600",
            output,
        ]
    )


def fix_videos(pattern):
    files = glob.glob(pattern)
    for file in files:
        ffmpeg = subprocess.run(
            [
                "ffmpeg",
                "-err_detect",
                "ignore_err",
                "-i",
                file,
                "-c",
                "copy",
                "-y",
                "fixed.mp4",
            ]
        )
        if ffmpeg.returncode == 0:
            move("fixed.mp4", file)
        else:
            os.remove("fixed.mp4")


def download(url, file):
    subprocess.run(
        ["yt-dlp", "--downloader", "aria2c", "--fixup", "warn", url, "-o", file]
    )


if __name__ == "__main__":
    sys.argv.pop(0)
    while len(sys.argv):
        arg = sys.argv.pop(0)
        if arg == "join":
            join_frags()
        elif arg == "split":
            if len(sys.argv) < 1:
                raise ValueError("Missing argument: file")
            file = sys.argv.pop(0)
            if len(sys.argv) < 1:
                raise ValueError("Missing argument: output")
            output = sys.argv.pop(0)
            split_video(file, output)
        elif arg == "fix":
            if len(sys.argv) < 1:
                raise ValueError("Missing argument: pattern")
            pattern = sys.argv.pop(0)
            fix_videos(pattern)
        elif arg == "download":
            if len(sys.argv) < 1:
                raise ValueError("Missing argument: url")
            url = sys.argv.pop(0)
            if len(sys.argv) < 1:
                raise ValueError("Missing argument: file")
            file = sys.argv.pop(0)
            download(url, file)
        elif arg == "help":
            print(
                """twitch.py <command>

commands:
  join
  split <file> <output>
  fix <pattern>
  download <url> <file>
  help
"""
            )
        else:
            raise ValueError(f"Unknown argument {arg}")
