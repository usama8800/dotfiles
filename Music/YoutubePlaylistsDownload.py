#!/usr/bin/python3

# Tchaikovsky https://en.wikipedia.org/wiki/List_of_compositions_by_Pyotr_Ilyich_Tchaikovsky
# Chopin https://en.wikipedia.org/wiki/List_of_compositions_by_Fr%C3%A9d%C3%A9ric_Chopin_by_opus_number
# Beethoven https://en.wikipedia.org/wiki/List_of_compositions_by_Ludwig_van_Beethoven
# Mozart https://en.wikipedia.org/wiki/List_of_compositions_by_Wolfgang_Amadeus_Mozart

import json
import os
import re
import shutil
import subprocess
import sys

from dotenv import load_dotenv

# External dependencies:
# - yt-dlp
# - ffmpeg
# - ffprobe
# - AtomicParsley


load_dotenv(".env.local")

if not os.path.exists("playlists.json"):
    raise FileNotFoundError("Missing playlists.json")
with open("playlists.json", "r") as f:
    playlists = json.load(f)
simulate = False
test = False


def remove(path):
    if not simulate:
        if not os.path.exists(path):
            return
        print("Removing " + path)
        if os.path.isdir(path):
            shutil.rmtree(path)
        else:
            os.remove(path)
    else:
        print("Would remove " + path)


def move(from_path, to_path, noprint=False):
    if not simulate:
        if not noprint:
            print("Moving " + from_path + " to " + to_path)
        if os.path.exists(to_path):
            os.replace(from_path, to_path)
        else:
            os.rename(from_path, to_path)
    elif not noprint:
        print("Would move " + from_path + " to " + to_path)


def id_from_filename(filename):
    return filename.split("- ")[-1].split(".")[0].strip()


def remove_duplicate_id_files():
    for playlist_name in playlists:
        files = os.listdir(os.path.join(os.environ["VIDEO_PATH"], playlist_name))
        encountered_ids = []
        double_ids = []
        for file in files:
            if file[0] == ".":
                continue
            if file.endswith(".temp.mp4"):
                remove(os.path.join(os.environ["VIDEO_PATH"], playlist_name, file))
                continue
            id = id_from_filename(file)
            if id not in encountered_ids:
                encountered_ids.append(id)
            else:
                double_ids.append(id)
        for file in files:
            if file[0] == ".":
                continue
            id = id_from_filename(file)
            if id in double_ids:
                move(
                    os.path.join(os.environ["VIDEO_PATH"], playlist_name, file),
                    os.path.join(
                        os.environ["VIDEO_PATH"],
                        "Removed",
                        playlist_name + " - " + file,
                    ),
                )


def remove_files_not_in_metadata():
    for playlist_name in playlists:
        files = os.listdir(os.path.join(os.environ["VIDEO_PATH"], playlist_name))
        metadata = None
        if ".metadata" in files:
            with open(
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, ".metadata"), "r"
            ) as f:
                metadata = list(map(lambda x: x.strip(), f.readlines()))
        if metadata is None or len(metadata) == 0:
            continue
        for file in files:
            if file[0] == ".":
                continue
            if id_from_filename(file) not in metadata:
                move(
                    os.path.join(os.environ["VIDEO_PATH"], playlist_name, file),
                    os.path.join(
                        os.environ["VIDEO_PATH"],
                        "Removed",
                        playlist_name + " - " + file,
                    ),
                )


def remove_audios_not_in_videos():
    for playlist_name in playlists:
        video_files = list(
            map(
                lambda x: os.path.splitext(x)[0],
                os.listdir(os.path.join(os.environ["VIDEO_PATH"], playlist_name)),
            )
        )
        audio_files = os.listdir(os.path.join(os.environ["AUDIO_PATH"], playlist_name))
        # print(video_files)
        for audio_file in audio_files:
            audio_file_name = os.path.splitext(audio_file)[0]
            # print(audio_file, audio_file_name)
            if audio_file_name not in video_files:
                remove(
                    os.path.join(os.environ["AUDIO_PATH"], playlist_name, audio_file)
                )


def remove_archive_ids_for_deleted_files():
    for playlist_name in playlists:
        files = os.listdir(os.path.join(os.environ["VIDEO_PATH"], playlist_name))
        delete_from_archive = None
        if ".archive" in files:
            with open(
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, ".archive"), "r"
            ) as f:
                delete_from_archive = list(map(lambda x: x.strip(), f.readlines()))
        if delete_from_archive is None or len(delete_from_archive) == 0:
            continue
        for file in files:
            if file[0] == ".":
                continue
            if "youtube " + id_from_filename(file) in delete_from_archive:
                delete_from_archive.remove("youtube " + id_from_filename(file))
        if len(delete_from_archive):
            with open(
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, ".archive"), "r"
            ) as f:
                archive = list(
                    filter(
                        lambda x: x.strip() not in delete_from_archive, f.readlines()
                    )
                )
            with open(
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, ".archive"), "w"
            ) as f:
                f.write("".join(archive))


def download_videos():
    for playlist_name, playlist in playlists.items():
        output_format = (
            playlist["output_format"]
            if "output_format" in playlist
            else "%(title)s - %(id)s.%(ext)s"
        )
        items = playlist["items"] if "items" in playlist else ":"
        print(f"Downloading playlist '{playlist_name}' with items '{items}'")
        ytdlp = subprocess.run(
            [
                "yt-dlp",
                "-f",
                "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best",
                "--no-mtime",
                "--playlist-items",
                items,
                "-o",
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, output_format),
                "--download-archive",
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, ".archive"),
                playlist["url"],
            ],
            check=True,
        )


def download_metadata():
    for playlist_name, playlist in playlists.items():
        print(f"Downloading metadata for '{playlist_name}'")
        items = playlist["items"] if "items" in playlist else ":"
        ytdlp = subprocess.run(
            [
                "yt-dlp",
                "--playlist-items",
                items,
                "-J",
                "--flat-playlist",
                playlist["url"],
            ],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        if ytdlp.returncode != 0:
            print(ytdlp.stderr)
            continue
        metadata = json.loads(ytdlp.stdout)
        with open(
            os.path.join(os.environ["VIDEO_PATH"], playlist_name, ".metadata"), "w"
        ) as f:
            for entry in metadata["entries"]:
                f.write(entry["id"] + "\n")


def cut_videos():
    for playlist_name in playlists:
        if "track_info" not in playlists[playlist_name]:
            continue
        track_info = playlists[playlist_name]["track_info"]
        files = os.listdir(os.path.join(os.environ["VIDEO_PATH"], playlist_name))
        for file in files:
            if not file.endswith(".mp4"):
                continue
            id = id_from_filename(file)
            if id not in track_info:
                continue
            start = track_info[id]["start"] if "start" in track_info[id] else 0
            end = track_info[id]["end"] if "end" in track_info[id] else None
            if start == 0 and end is None:
                continue
            length = get_video_length(
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, file)
            )
            secs_start = hhmmToSecs(start)
            secs_end = hhmmToSecs(end)
            diff = length - (secs_end - secs_start)
            if diff <= 1:
                continue
            if secs_end > length:
                move(
                    os.path.join(os.environ["VIDEO_PATH"], playlist_name, file),
                    os.path.join(
                        os.environ["VIDEO_PATH"],
                        "Removed",
                        playlist_name + " - " + file,
                    ),
                )
                continue
            print(f"Cutting {file} from {start} to {end}")
            command = [
                "ffmpeg",
                "-y",
                "-i",
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, file),
            ]
            if start != 0:
                command.extend(
                    [
                        "-ss",
                        str(start),
                    ]
                )
            if end is not None:
                command.extend(
                    [
                        "-to",
                        str(end),
                    ]
                )
            command.extend(["-c:v", "libx264"])
            command.extend(["-c:a", "aac"])
            command.append(
                os.path.join(
                    os.environ["VIDEO_PATH"], playlist_name, file + ".temp.mp4"
                )
            )
            ffmpeg = subprocess.run(command)
            if ffmpeg.returncode != 0:
                print(f"ffmpeg failed to cut {file}")
                continue
            remove(
                os.path.join(
                    os.environ["AUDIO_PATH"],
                    playlist_name,
                    os.path.splitext(file)[0] + ".mp3",
                )
            )
            move(
                os.path.join(
                    os.environ["VIDEO_PATH"], playlist_name, file + ".temp.mp4"
                ),
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, file),
                True,
            )


def tag_videos():
    for playlist_name in playlists:
        if "track_info" not in playlists[playlist_name]:
            print(f"No track info for {playlist_name}")
            continue
        track_info = playlists[playlist_name]["track_info"]
        files = os.listdir(os.path.join(os.environ["VIDEO_PATH"], playlist_name))
        for file in files:
            if not file.endswith(".mp4") or file[0] == ".":
                continue
            id = id_from_filename(file)
            if id not in track_info:
                print(f'ID "{id}" not in track info for {playlist_name}')
                continue
            old_title, old_artist, old_genre = get_atomic_parsley_data(
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, file)
            )
            # AtomicParsley --longhelp
            # AtomicParsley --genre-list
            command = [
                "AtomicParsley",
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, file),
                "--overWrite",
            ]
            if "title" not in track_info[id]:
                print(f"No title for id {id}")
            elif old_title != track_info[id]["title"]:
                command.extend(["--title", track_info[id]["title"]])
            if "artist" not in track_info[id]:
                print(f"No artist for id {id}")
            elif old_artist != track_info[id]["artist"]:
                command.extend(["--artist", track_info[id]["artist"]])
            if "genre" not in track_info[id]:
                print(f"No genre for id {id}")
            elif old_genre != track_info[id]["genre"]:
                command.extend(["--genre", track_info[id]["genre"]])
            if len(command) == 3:
                continue
            print(f"Tagging {file}")
            atomic_parsley = subprocess.run(command)
            if atomic_parsley.returncode != 0:
                print(f"AtomicParsley failed to run for {file}")
                continue
            remove(
                os.path.join(
                    os.environ["AUDIO_PATH"],
                    playlist_name,
                    os.path.splitext(file)[0] + ".mp3",
                )
            )


def convert_to_mp3s():
    for playlist_name in playlists:
        os.makedirs(
            os.path.join(os.environ["AUDIO_PATH"], playlist_name), exist_ok=True
        )
        files = os.listdir(os.path.join(os.environ["VIDEO_PATH"], playlist_name))
        for file in files:
            if not file.endswith(".mp4"):
                continue
            output_filename = os.path.join(
                os.environ["AUDIO_PATH"], playlist_name, file[:-4] + ".mp3"
            )
            if os.path.exists(output_filename):
                continue
            print(f"Converting {file} to mp3")
            ffmpeg = subprocess.run(
                [
                    "ffmpeg",
                    "-y",
                    "-i",
                    os.path.join(os.environ["VIDEO_PATH"], playlist_name, file),
                    "-codec:a",
                    "libmp3lame",
                    "-qscale:a",
                    "0",
                    output_filename + ".temp.mp3",
                ],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
            if ffmpeg.returncode != 0:
                print(f"ffmpeg failed to convert {file} to {output_filename}")
                continue
            os.rename(output_filename + ".temp.mp3", output_filename)


def get_atomic_parsley_data(file):
    title = ""
    artist = ""
    genre = ""
    command = [
        "AtomicParsley",
        file,
        "-t",
    ]
    atomic_parsley = subprocess.run(command, stdout=subprocess.PIPE, text=True)
    if atomic_parsley.returncode == 0:
        output = atomic_parsley.stdout.splitlines()
        regex = re.compile(r"^.?Atom \"(.+?)\" contains: (.*)$")
        for line in output:
            match = regex.match(line)
            if match:
                if match.group(1).endswith("nam"):
                    title = match.group(2)
                elif match.group(1).endswith("ART"):
                    artist = match.group(2)
                elif match.group(1) == "gnre":
                    genre = match.group(2)
    return title, artist, genre


def get_video_length(file):
    command = [
        "ffprobe",
        "-v",
        "error",
        "-show_streams",
        "-select_streams",
        "v:0",
        "-of",
        "json",
        file,
    ]
    ffprobe = subprocess.run(command, stdout=subprocess.PIPE)
    output = json.loads(ffprobe.stdout)
    streams = output["streams"]
    stream = streams[0]
    duration = stream["duration"]
    return int(float(duration))


def hhmmToSecs(hhmmss):
    try:
        return int(hhmmss)
    except:
        parts = hhmmss.split(":")
        secs = 0
        if len(parts) == 3:
            secs += int(parts[0]) * 60 * 60
            parts = parts[1:]
        secs += int(parts[0]) * 60 + int(parts[1])
        return secs


def clean():
    remove_duplicate_id_files()
    remove_files_not_in_metadata()
    remove_archive_ids_for_deleted_files()
    remove_audios_not_in_videos()


def main():
    os.makedirs(os.path.join(os.environ["VIDEO_PATH"], "Removed"), exist_ok=True)
    os.makedirs(os.environ["AUDIO_PATH"], exist_ok=True)

    remove_duplicate_id_files()
    remove_archive_ids_for_deleted_files()

    download_videos()
    download_metadata()

    remove_duplicate_id_files()
    remove_files_not_in_metadata()
    remove_archive_ids_for_deleted_files()

    cut_videos()
    tag_videos()
    convert_to_mp3s()

    remove_audios_not_in_videos()


def set_test():
    global test
    global playlists
    test = True
    playlists = {
        "Down with the Atriarchy": {
            "url": "https://www.youtube.com/playlist?list=PLnnmg4FEileQGTodcPMvqYo79LtTZVpDV",
            "output_format": "%(playlist_index)02d - %(title)s - %(id)s.%(ext)s",
            "items": "2,3",
        }
    }
    if "TEST_VIDEO_PATH" not in os.environ:
        raise ValueError("Missing environment variable TEST_VIDEO_PATH")
    if "TEST_AUDIO_PATH" not in os.environ:
        raise ValueError("Missing environment variable TEST_AUDIO_PATH")
    os.environ["VIDEO_PATH"] = os.environ["TEST_VIDEO_PATH"]
    os.environ["AUDIO_PATH"] = os.environ["TEST_AUDIO_PATH"]


if __name__ == "__main__":
    if "SIMULATE" in os.environ and os.environ["SIMULATE"].lower() in [
        "true",
        "1",
        "yes",
    ]:
        simulate = True
    if "TEST" in os.environ and os.environ["TEST"].lower() in ["true", "1", "yes"]:
        set_test()
    if "VIDEO_PATH" not in os.environ:
        raise ValueError("Missing environment variable VIDEO_PATH")
    if "AUDIO_PATH" not in os.environ:
        raise ValueError("Missing environment variable AUDIO_PATH")

    if len(sys.argv) == 1:
        main()
    else:
        for arg in sys.argv[1:]:
            if arg == "download":
                download_videos()
            elif arg == "metadata":
                download_metadata()
            elif arg == "cut":
                cut_videos()
            elif arg == "convert":
                convert_to_mp3s()
            elif arg == "clean":
                clean()
            elif arg == "tag":
                tag_videos()
            elif arg == "help":
                print(
                    """
Usage:
    YoutubePlaylistsDownload.py <commands>

Commands:
    download
    metadata
    cut
    convert
    clean
    tag
    help"""
                )
            else:
                raise ValueError(f"Unknown argument {arg}")
