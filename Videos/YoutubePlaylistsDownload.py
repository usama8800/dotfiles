#!/usr/bin/env python3

import datetime
import json
import math
import os
import re
import shutil
import subprocess
import sys
import time

if not os.path.exists("playlists.json"):
    raise FileNotFoundError("Missing playlists.json")
with open("playlists.json", "r") as f:
    playlists = json.load(f)
    playlists = dict(
        filter(
            lambda item: "disabled" not in item[1] or not item[1]["disabled"],
            playlists.items(),
        )
    )
    for playlist_name in playlists:
        if "url" not in playlists[playlist_name]:
            raise ValueError(
                f"Missing url for playlist {playlist_name} in playlists.json"
            )
        if "min_date" not in playlists[playlist_name]:
            playlists[playlist_name]["min_date"] = "1970-01-01"
        if "ids_desc_print_skip" not in playlists[playlist_name]:
            playlists[playlist_name]["ids_desc_print_skip"] = []
        if "ongoing" not in playlists[playlist_name]:
            playlists[playlist_name]["ongoing"] = False
        if "accurate" not in playlists[playlist_name]:
            playlists[playlist_name]["accurate"] = False
        if "path" not in playlists[playlist_name]:
            playlists[playlist_name]["path"] = playlist_name
        if "max_count" not in playlists[playlist_name]:
            playlists[playlist_name]["max_count"] = 100

dump_filename = ".dump.json"
videos_filename = ".videos.json"
downloading_folder = "Downloading"
bytes_per_second = 463_000
min_space_left = 2


def natural_sort(l, k=None):
    convert = lambda text: int(text) if text.isdigit() else text.lower()
    alphanum_key = lambda key: [
        convert(c) for c in re.split("([0-9]+)", key[k] if k else key)
    ]
    return sorted(l, key=alphanum_key)


def download_metadata(force=False):
    for playlist_name in playlists:
        path = playlists[playlist_name]["path"]
        if not os.path.exists(path):
            os.mkdir(path)
        dump_filepath = os.path.join(path, dump_filename)
        videos_filepath = os.path.join(path, videos_filename)

        if (
            not force
            and os.path.exists(dump_filepath)
            and os.path.exists(videos_filepath)
        ):
            modified_time = os.path.getmtime(videos_filepath)
            time_difference = time.time() - modified_time
            hours_difference = time_difference / 3600
            if hours_difference < 6:
                continue

        if (
            not playlists[playlist_name]["ongoing"]
            and os.path.exists(dump_filepath)
            and os.path.exists(videos_filepath)
            and not force
        ):
            continue

        print(f"Downloading metadata for {playlist_name}")
        with open(dump_filepath, "w") as f:
            ytdlp = subprocess.run(
                [
                    "yt-dlp",
                    "-J",
                    "--flat-playlist",
                    "--extractor-args",
                    "youtubetab:approximate_date",
                    playlists[playlist_name]["url"],
                ],
                stdout=f,
                stderr=subprocess.PIPE,
                text=True,
            )
            if ytdlp.returncode != 0:
                print(ytdlp.stderr)
                sys.exit(ytdlp.returncode)

        with open(dump_filepath, "r") as f:
            metadata = json.loads(f.read())

        videos = []
        atrioc_pattern = r"Streamed Live on (January|February|March|April|May|June|July|August|September|October|November|December) (\d{1,2})(?:.*?),? (\d{4})"
        for entry in metadata["entries"]:
            if playlist_name == "Atrioc":
                match = re.search(atrioc_pattern, entry["description"])
                if match:
                    month_name, day, year = match.groups()
                    date_object = datetime.datetime.strptime(
                        f"{month_name} {day} {year}", "%B %d %Y"
                    )
                else:
                    if (
                        entry["id"]
                        not in playlists[playlist_name]["ids_desc_print_skip"]
                    ):
                        print(f"No date found in the description for {entry['id']}")
                        print(entry["description"])
                    date_object = datetime.datetime.fromtimestamp(entry["timestamp"])
            else:
                # Private video
                if entry["timestamp"] is None:
                    continue
                date_object = datetime.datetime.fromtimestamp(entry["timestamp"])
            videos.append(
                {
                    "id": entry["id"],
                    "url": entry["url"],
                    "title": entry["title"],
                    "date": date_object.strftime("%Y-%m-%d"),
                }
            )
        if playlists[playlist_name]["ongoing"]:
            videos = sorted(videos, key=lambda x: x["date"], reverse=False)
        with open(videos_filepath, "w") as f:
            json.dump(videos, f, indent=4)


def download_videos():
    if not os.path.exists(downloading_folder):
        os.mkdir(downloading_folder)
    for playlist_name in playlists:
        printed_about_downloading_playlist = False
        path = playlists[playlist_name]["path"]
        if os.path.exists(os.path.join(path, ".archive")):
            with open(os.path.join(path, ".archive"), "r") as f:
                archive = [line.strip() for line in f.readlines()]
        else:
            archive = []
        with open(os.path.join(path, videos_filename), "r") as f:
            videos = json.loads(f.read())
        for i, video in enumerate(videos):
            download_count = len(
                list(filter(lambda f: f.endswith(".mp4"), os.listdir(path)))
            )
            if download_count >= playlists[playlist_name]["max_count"]:
                break
            if (
                video["date"] < playlists[playlist_name]["min_date"]
                or f"youtube {video['id']}" in archive
            ):
                continue

            if not printed_about_downloading_playlist:
                print(f"Downloading videos for {playlist_name}")
                printed_about_downloading_playlist = True

            print(f"Checking space for {video['title']}")
            space_left = compare_free_space_with_video(video["url"])
            if space_left < min_space_left:
                break
            output_name = f"%(title)s [%(id)s].%(ext)s"
            if playlists[playlist_name]["ongoing"]:
                output_name = f"{video['date']} - {output_name}"
            else:
                output_name = (
                    f"{i+1:0{math.floor(math.log10(len(videos))) + 1}} - {output_name}"
                )
            if playlists[playlist_name]["accurate"]:
                output_name = f"%(upload_date)s {output_name}"
            ytdlp = subprocess.run(
                [
                    "yt-dlp",
                    "-f",
                    "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best",
                    "--downloader",
                    "aria2c",
                    "--download-archive",
                    (
                        os.path.join(path, ".archive")
                        if os.path.isabs(path)
                        else os.path.join("..", path, ".archive")
                    ),
                    "-o",
                    output_name,
                    video["url"],
                ],
                cwd=downloading_folder,
                check=True,
            )
            if ytdlp.returncode != 0:
                print(ytdlp.stderr)
                continue
            download_count += 1
            clean_downloading_folder(video["id"], path)
    shutil.rmtree(downloading_folder)


def clean_downloading_folder(id, copy_to, to_filename=None):
    for filename in os.listdir(downloading_folder):
        if filename.find(f"[{id}]"):
            if to_filename is None:
                to_filename = filename
            if filename.endswith(".mp4") or filename.endswith(".webm"):
                bps = find_bytes_per_second(os.path.join("Downloading", filename))
                if bps > bytes_per_second:
                    print(f"NEW LARGEST BYTES PER SECOND: {bps}")
                shutil.move(
                    os.path.join("Downloading", filename),
                    os.path.join(copy_to, to_filename),
                )
            else:
                os.remove(os.path.join("Downloading", filename))


def compare_free_space_with_video(video_url):
    free_space = shutil.disk_usage(".").free
    ytdlp = subprocess.run(
        ["yt-dlp", "--print", "%(filesize)s,%(duration)s", video_url],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if ytdlp.returncode != 0:
        print(ytdlp.stderr)
        return 0
    filesize, duration = ytdlp.stdout.split(",")
    try:
        filesize = int(filesize)
    except ValueError:
        filesize = int(duration) * bytes_per_second

    free_gbs = free_space / 1024.0 / 1024 / 1024
    video_gbs = int(filesize) / 1024.0 / 1024 / 1024
    print(f"{video_gbs:.2f} / {free_gbs:.2f} GB")
    return free_gbs - video_gbs


def find_bytes_per_second(filepath):
    probe = subprocess.run(
        [
            "ffprobe",
            "-v",
            "error",
            "-show_entries",
            "format=duration",
            "-of",
            "default=noprint_wrappers=1:nokey=1",
            filepath,
        ],
        text=True,
        check=True,
        stdout=subprocess.PIPE,
    )
    filesize = os.path.getsize(filepath)
    duration = float(probe.stdout)
    return filesize / duration


def find_all_bytes_per_second():
    arr = []
    for filename in os.listdir("Atrioc"):
        if filename.startswith("."):
            continue
        arr.append(find_bytes_per_second(os.path.join("Atrioc", filename)))
    arr = sorted(arr)
    print("\n".join(map(lambda x: str(int(x)), arr)))


def main():
    download_metadata()
    download_videos()


if __name__ == "__main__":
    if len(sys.argv) == 1:
        main()
    else:
        for arg in sys.argv[1:]:
            if arg == "download":
                download_videos()
            elif arg == "metadata":
                download_metadata()
            elif arg == "metadata-force":
                download_metadata(True)
            elif arg == "bps":
                find_all_bytes_per_second()
            elif arg == "help":
                print(
                    """
Usage:
    index.py <commands>

Commands:
    download
    metadata
    help"""
                )
            else:
                raise ValueError(f"Unknown argument {arg}")
