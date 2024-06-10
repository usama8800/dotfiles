#!/usr/bin/python3

import json
import os
import subprocess
import sys

from dotenv import load_dotenv

load_dotenv()

simulate = False
test = False

playlists = {
    "Down with the Atriarchy": {
        "url": "https://www.youtube.com/playlist?list=PLnnmg4FEileQGTodcPMvqYo79LtTZVpDV",
        "output_format": "%(playlist_index)02d - %(title)s - %(id)s.%(ext)s",
        "items": "2-4,6-12,14-16,19-24,26,28,30",
    },
    "Best Classics": {
        "url": "https://www.youtube.com/playlist?list=PLZY56D5QXJZ9IISu_gzegHwZURZYFQc8z",
    },
    "Random Music": {
        "url": "https://www.youtube.com/playlist?list=PLZY56D5QXJZ_WyaiL6BlA7dV2UiwZOzzn",
    },
}


def remove(path):
    if not simulate:
        print('Removing ' + path)
        os.remove(path)
    else:
        print('Would remove ' + path)


def move(from_path, to_path):
    if not simulate:
        print('Moving ' + from_path + ' to ' + to_path)
        os.rename(from_path, to_path)
    else:
        print('Would move ' + from_path + ' to ' + to_path)


def prepost():
    for playlist in playlists:
        video_playlist_path = os.path.join(os.environ["VIDEO_PATH"], playlist)
        audio_playlist_path = os.path.join(os.environ["AUDIO_PATH"], playlist)
        if not os.path.isdir(video_playlist_path):
            subprocess.run(["rm", "-rf", audio_playlist_path],
                           stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            continue

        video_files = os.listdir(video_playlist_path)
        try:
            audio_files = os.listdir(audio_playlist_path)
        except FileNotFoundError as e:
            print(e)
            audio_files = []
        metadata = None  # list of updated playlist video ids
        delete_from_archive = None  # list of previously downloaded video ids
        encountered_ids = []
        double_ids = []

        # load data
        if '.metadata' in video_files:
            with open(os.path.join(video_playlist_path, '.metadata'), 'r') as f:
                metadata = list(map(lambda x: x.strip(), f.readlines()))
        else:
            continue
        if '.archive' in video_files:
            with open(os.path.join(video_playlist_path, '.archive'), 'r') as f:
                delete_from_archive = list(
                    map(lambda x: x.strip(), f.readlines()))
        else:
            continue
        if metadata is None or len(metadata) == 0:
            continue

        for file in video_files:
            if file[0] == '.':
                continue
            video_id = file.split('- ')[-1].split('.')[0].strip()

            # check for double ids
            if video_id not in encountered_ids:
                encountered_ids.append(video_id)
            else:
                print('Double id ' + video_id)
                double_ids.append(video_id)

            # delete video if not in playlist
            deleted = False
            if video_id not in metadata:
                move(os.path.join(video_playlist_path, file),
                     os.path.join(os.environ["VIDEO_PATH"], 'Removed', file))
                deleted = True
            if not deleted and 'youtube '+video_id in delete_from_archive:
                delete_from_archive.remove('youtube '+video_id)

        # delete both videos from double ids and from archive
        for file in video_files:
            if file[0] == '.':
                continue
            video_id = file.split('- ')[-1].split('.')[0].strip()

            if video_id in double_ids:
                remove(os.path.join(video_playlist_path, file))
                if 'youtube '+video_id not in delete_from_archive:
                    delete_from_archive.append('youtube '+video_id)

        encountered_ids = []
        double_ids = []
        for file in audio_files:
            if file[0] == '.':
                continue
            audio_id = file.split('- ')[-1].split('.')[0].strip()

            # ffmpeg stopped before finishing
            if file.endswith('.temp.mp3'):
                remove(os.path.join(audio_playlist_path, file))

            # delete audio if not in playlist
            if audio_id not in metadata:
                remove(os.path.join(audio_playlist_path, file))

        # delete both audios from double ids
        for file in audio_files:
            if file[0] == '.':
                continue
            audio_id = file.split('- ')[-1].split('.')[0].strip()

            if audio_id in double_ids:
                remove(os.path.join(audio_playlist_path, file))

        # remove deleted videos from archive
        if len(delete_from_archive):
            archive = None
            with open(os.path.join(video_playlist_path, '.archive'), 'r') as f:
                archive = list(filter(lambda x: x.strip()
                                      not in delete_from_archive, f.readlines()))
            with open(os.path.join(video_playlist_path, '.archive'), 'w') as f:
                f.write(''.join(archive))


def main():
    os.makedirs(os.path.join(
        os.environ["VIDEO_PATH"], "Removed"), exist_ok=True)
    os.makedirs(os.environ["AUDIO_PATH"], exist_ok=True)
    prepost()

    for playlist_name, playlist in playlists.items():
        output_format = playlist[
            "output_format"] if "output_format" in playlist else "%(title)s - %(id)s.%(ext)s"
        items = playlist["items"] if "items" in playlist else ":"
        print(f"Downloading playlist '{playlist_name}' with items '{items}'")
        ytdlp = subprocess.run([
            "yt-dlp",
            "-f",
            "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best",
            "--no-mtime",
            "--playlist-items", items,
            "-o", os.path.join(os.environ["VIDEO_PATH"],
                               playlist_name, output_format),
            "--download-archive", os.path.join(
                os.environ["VIDEO_PATH"], playlist_name, ".archive"),
            playlist["url"]
        ], check=True)
        ytdlp = subprocess.run([
            "yt-dlp",
            "--playlist-items", items,
            "-J", "--flat-playlist",
            playlist["url"],
        ], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if ytdlp.returncode != 0:
            print(ytdlp.stderr)
            continue
        metadata = json.loads(ytdlp.stdout)
        with open(os.path.join(os.environ["VIDEO_PATH"], playlist_name, ".metadata"), "w") as f:
            for entry in metadata["entries"]:
                f.write(entry["id"] + "\n")
    prepost()

    for playlist_name in playlists:
        os.makedirs(os.path.join(
            os.environ["AUDIO_PATH"], playlist_name), exist_ok=True)
        files = os.listdir(os.path.join(
            os.environ["VIDEO_PATH"], playlist_name))
        for file in files:
            if not file.endswith('.mp4'):
                continue
            output_filename = os.path.join(
                os.environ["AUDIO_PATH"], playlist_name, file[:-4] + '.mp3')
            if os.path.exists(output_filename):
                continue
            print(f"Converting {file} to {output_filename}")
            ffmpeg = subprocess.run([
                "ffmpeg",
                "-i",
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, file),
                "-codec:a", "libmp3lame", "-qscale:a", "0",
                output_filename + ".temp.mp3"
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if ffmpeg.returncode != 0:
                print(f"ffmpeg failed to convert {file} to {output_filename}")
                continue
            os.rename(output_filename + ".temp.mp3", output_filename)


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
    if "SIMULATE" in os.environ and os.environ["SIMULATE"].lower() in ["true", "1", "yes"]:
        simulate = True
    if "TEST" in os.environ and os.environ["TEST"].lower() in ["true", "1", "yes"]:
        set_test()
    if "VIDEO_PATH" not in os.environ:
        raise ValueError("Missing environment variable VIDEO_PATH")
    if "AUDIO_PATH" not in os.environ:
        raise ValueError("Missing environment variable AUDIO_PATH")

    main()
