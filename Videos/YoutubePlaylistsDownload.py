#!/usr/bin/python3

import datetime
import json
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
dump_filename = ".dump.json"
videos_filename = ".videos.json"
downloading_folder = "Downloading"


def download_metadata(force=False):
    for playlist_name in playlists:
        if not os.path.exists(playlist_name):
            os.mkdir(playlist_name)
        dump_filepath = os.path.join(playlist_name, dump_filename)
        videos_filepath = os.path.join(playlist_name, videos_filename)

        if (
            not force
            and os.path.exists(dump_filepath)
            and os.path.exists(videos_filepath)
        ):
            modified_time = os.path.getmtime(dump_filepath)
            time_difference = time.time() - modified_time
            days_difference = time_difference // (24 * 3600)
            if days_difference < 1:
                return

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
                date_object = datetime.datetime.fromtimestamp(entry["timestamp"])
            videos.append(
                {
                    "id": entry["id"],
                    "url": entry["url"],
                    "title": entry["title"],
                    "date": date_object.strftime("%Y-%m-%d"),
                }
            )

        with open(videos_filepath, "w") as f:
            json.dump(videos, f, indent=4)


def download_videos():
    if not os.path.exists(downloading_folder):
        os.mkdir(downloading_folder)
    for playlist_name in playlists:
        print(f"Downloading videos for {playlist_name}")
        with open(os.path.join(playlist_name, ".archive"), "r") as f:
            archive = [line.strip() for line in f.readlines()]
        with open(os.path.join(playlist_name, videos_filename), "r") as f:
            videos = json.loads(f.read())
        videos.reverse()
        for video in videos:
            if (
                video["date"] < playlists[playlist_name]["min_date"]
                or f"youtube {video['id']}" in archive
            ):
                continue

            print(f"Checking space for {video['title']}")
            space_left = compare_free_space_with_video(video["url"])
            if space_left < 2:
                break
            ytdlp = subprocess.run(
                [
                    "yt-dlp",
                    "--downloader",
                    "aria2c",
                    "--download-archive",
                    os.path.join("..", playlist_name, ".archive"),
                    video["url"],
                ],
                cwd=downloading_folder,
                check=True,
            )
            if ytdlp.returncode != 0:
                print(ytdlp.stderr)
                continue
            clean_downloading_folder(video["id"], playlist_name)


def clean_downloading_folder(id, playlist_name):
    for filename in os.listdir(downloading_folder):
        if filename.find(f"[{id}]"):
            print(filename)
            if filename.endswith(".mp4") or filename.endswith(".webm"):
                shutil.move(
                    os.path.join("Downloading", filename),
                    os.path.join(playlist_name, filename),
                )
            else:
                os.remove(os.path.join("Downloading", filename))


def compare_free_space_with_video(video_url):
    free_space = shutil.disk_usage(".").free
    ytdlp = subprocess.run(
        ["yt-dlp", "--print", "%(filesize,filesize_approx)s", video_url],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    if ytdlp.returncode != 0:
        print(ytdlp.stderr)
        return 0

    free_gbs = free_space / 1024 / 1024 / 1024
    video_gbs = int(ytdlp.stdout) / 1024 / 1024 / 1024
    print(f"{video_gbs:.2f} / {free_gbs:.2f} GB")
    return free_gbs - video_gbs


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
