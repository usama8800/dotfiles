#!/usr/bin/python3

import json
import os
import shutil
import subprocess
import sys

from dotenv import load_dotenv

load_dotenv('.env.local')

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
start_end_times = {
    "E_GT8CPcIkg": (5, "12:42"),
    "3TiYGxOQDYw": (28, "38:17"),
    "Y7JxLgf3wLM": (6, "4:14"),
    "VbEcIBW3ohI": (0, "7:39"),
    "s_ST3hzMsVE": (0, "4:19"),
    "sf9CtbLGzgw": (0, "2:03"),
    "uOmaQSqnPfw": (17, "43:28"),
    "_5h4Y66HnG0": (8, "5:43"),
    "7VWHBHeNrg4": (0, "2:38"),
    "DVWaIJsIzao": (0, "9:52"),
    "dBwEXRz3A40": (12, "4:54"),
    "wQDoN40-_C4": (23, "7:29"),
    "9Wcgm-JLzM4": (11, "6:59"),
    "ynCEvFaJCZg": (0, "2:38"),
    "I3Nx3DjAx2s": (3, "37:28"),
    "wSPbSZM1rUE": (0, "23:28"),
    "ksRiOHOzG7Q": (0, "3:01"),
    "cmNEvSFWftc": (0, "14:43"),
    "hAFn2J6FEbI": (0, "2:38"),
    "I03Hs6dwj7E": (18, "28:34"),
    "zY4w4_W30aQ": (4, "50:44"),
    "lVfl4g8btAM": (4, "2:11"),
    "QR10Od1cLaM": (0, "4:10"),
    "J0w0t4Qn6LY": (24, "36:09"),
    "6tqOMxaGgBU": (1, "3:12"),
    "l6kqu2mk-Kw": (0, "13:21"),
    "u7zbHlJsCQs": (6, "8:26"),
    "xIY07cP7hQU": (6, "3:15"),
    "gb2h24lTqho": (7, "9:04"),
    "hNfpMRSCFPE": (3, "36:52"),
    "LdH1hSWGFGU": (0, "9:34"),
    "wwaSSQnceu8": (0, "2:49"),
    "UWg5ugyMjIc": (0, "3:20"),
    "1prweT95Mo0": (8, "2:36"),
    "b_E51SV0Zus": (16, "4:05"),
}


def remove(path):
    if not simulate:
        print('Removing ' + path)
        if not os.path.exists(path):
            return
        if os.path.isdir(path):
            shutil.rmtree(path)
        else:
            os.remove(path)
    else:
        print('Would remove ' + path)


def move(from_path, to_path):
    if not simulate:
        print('Moving ' + from_path + ' to ' + to_path)
        os.rename(from_path, to_path)
    else:
        print('Would move ' + from_path + ' to ' + to_path)


def id_from_filename(filename):
    return filename.split('- ')[-1].split('.')[0].strip()


def remove_duplicate_id_files():
    for playlist_name in playlists:
        files = os.listdir(os.path.join(
            os.environ["VIDEO_PATH"], playlist_name))
        encountered_ids = []
        double_ids = []
        for file in files:
            if file[0] == '.':
                continue
            if file.endswith('.temp.mp4'):
                remove(os.path.join(
                    os.environ["VIDEO_PATH"], playlist_name, file))
                continue
            id = id_from_filename(file)
            if id not in encountered_ids:
                encountered_ids.append(id)
            else:
                double_ids.append(id)
        for file in files:
            if file[0] == '.':
                continue
            id = id_from_filename(file)
            if id in double_ids:
                remove(os.path.join(
                    os.environ["VIDEO_PATH"], playlist_name, file))


def remove_files_not_in_metadata():
    for playlist_name in playlists:
        files = os.listdir(os.path.join(
            os.environ["VIDEO_PATH"], playlist_name))
        metadata = None
        if '.metadata' in files:
            with open(os.path.join(os.environ["VIDEO_PATH"], playlist_name, '.metadata'), 'r') as f:
                metadata = list(map(lambda x: x.strip(), f.readlines()))
        if metadata is None or len(metadata) == 0:
            continue
        for file in files:
            if file[0] == '.':
                continue
            if id_from_filename(file) not in metadata:
                move(os.path.join(
                    os.environ["VIDEO_PATH"], playlist_name, file), os.path.join(os.environ["VIDEO_PATH"], "Removed", playlist_name+" - "+file))


def remove_audios_not_in_videos():
    for playlist_name in playlists:
        video_files = list(map(
            lambda x: os.path.splitext(x)[0],
            os.listdir(os.path.join(
                os.environ["VIDEO_PATH"], playlist_name))))
        audio_files = os.listdir(os.path.join(
            os.environ["AUDIO_PATH"], playlist_name))
        # print(video_files)
        for audio_file in audio_files:
            audio_file_name = os.path.splitext(audio_file)[0]
            # print(audio_file, audio_file_name)
            if audio_file_name not in video_files:
                remove(os.path.join(
                    os.environ["AUDIO_PATH"], playlist_name, audio_file))


def remove_archive_ids_for_deleted_files():
    for playlist_name in playlists:
        files = os.listdir(os.path.join(
            os.environ["VIDEO_PATH"], playlist_name))
        delete_from_archive = None
        if '.archive' in files:
            with open(os.path.join(os.environ["VIDEO_PATH"], playlist_name, '.archive'), 'r') as f:
                delete_from_archive = list(
                    map(lambda x: x.strip(), f.readlines()))
        if delete_from_archive is None or len(delete_from_archive) == 0:
            continue
        for file in files:
            if file[0] == '.':
                continue
            if 'youtube '+id_from_filename(file) in delete_from_archive:
                delete_from_archive.remove('youtube '+id_from_filename(file))
        if len(delete_from_archive):
            with open(os.path.join(os.environ["VIDEO_PATH"], playlist_name, '.archive'), 'r') as f:
                archive = list(filter(lambda x: x.strip()
                                      not in delete_from_archive, f.readlines()))
            with open(os.path.join(os.environ["VIDEO_PATH"], playlist_name, '.archive'), 'w') as f:
                f.write(''.join(archive))


def download_videos():
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


def download_metadata():
    for playlist_name, playlist in playlists.items():
        print(f"Downloading metadata for '{playlist_name}'")
        items = playlist["items"] if "items" in playlist else ":"
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


def cut_videos():
    already_cut = []
    if os.path.exists(os.path.join(os.environ["VIDEO_PATH"], ".cut_ids")):
        with open(os.path.join(os.environ["VIDEO_PATH"], ".cut_ids"), 'r') as f:
            already_cut = list(map(lambda x: x.strip(), f.readlines()))
    for playlist_name in playlists:
        files = os.listdir(os.path.join(
            os.environ["VIDEO_PATH"], playlist_name))
        for file in files:
            if not file.endswith('.mp4') or file[0] == '.':
                continue
            id = id_from_filename(file)
            if id not in start_end_times or id in already_cut:
                continue
            start, end = start_end_times[id]
            print(f"Cutting {file} from {start} to {end}")
            command = [
                "ffmpeg", "-y",
                "-i", os.path.join(os.environ["VIDEO_PATH"],
                                   playlist_name, file),
                "-ss", str(start),
                "-to", str(end),
            ]
            # if start == 0:
            #     command.extend(["-c", "copy"])
            # else:
            command.extend(["-c:v", "libx264"])
            command.extend(["-c:a", "aac"])
            command.append(os.path.join(os.environ["VIDEO_PATH"],
                                        playlist_name, file+'.temp.mp4'))
            ffmpeg = subprocess.run(command)
            if ffmpeg.returncode != 0:
                print(f"ffmpeg failed to cut {file}")
                continue
            remove(os.path.join(
                os.environ["AUDIO_PATH"], playlist_name, os.path.splitext(file)[0]+'.mp3'))
            os.replace(os.path.join(os.environ["VIDEO_PATH"], playlist_name, file+'.temp.mp4'),
                       os.path.join(os.environ["VIDEO_PATH"], playlist_name, file))
            already_cut.append(id)
            with open(os.path.join(os.environ["VIDEO_PATH"], ".cut_ids"), "a") as f:
                f.write(id + "\n")


def convert_to_mp3s():
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
            print(f"Converting {file} to mp3")
            ffmpeg = subprocess.run([
                "ffmpeg",
                "-y",
                "-i",
                os.path.join(os.environ["VIDEO_PATH"], playlist_name, file),
                "-codec:a", "libmp3lame", "-qscale:a", "0",
                output_filename + ".temp.mp3"
            ], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            if ffmpeg.returncode != 0:
                print(f"ffmpeg failed to convert {file} to {output_filename}")
                continue
            os.rename(output_filename + ".temp.mp3", output_filename)


def clean():
    remove_duplicate_id_files()
    remove_files_not_in_metadata()
    remove_archive_ids_for_deleted_files()
    remove_audios_not_in_videos()


def main():
    os.makedirs(os.path.join(
        os.environ["VIDEO_PATH"], "Removed"), exist_ok=True)
    os.makedirs(os.environ["AUDIO_PATH"], exist_ok=True)

    remove_duplicate_id_files()
    remove_archive_ids_for_deleted_files()

    download_videos()
    download_metadata()

    remove_duplicate_id_files()
    remove_files_not_in_metadata()
    remove_archive_ids_for_deleted_files()

    cut_videos()
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
    if "SIMULATE" in os.environ and os.environ["SIMULATE"].lower() in ["true", "1", "yes"]:
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
            if arg == 'download':
                download_videos()
            elif arg == 'metadata':
                download_metadata()
            elif arg == 'cut':
                cut_videos()
            elif arg == 'convert':
                convert_to_mp3s()
            elif arg == 'clean':
                clean()
            else:
                raise ValueError(f"Unknown argument {arg}")
