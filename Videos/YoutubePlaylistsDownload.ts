#!/usr/bin/env -S npx tsx

import { program } from 'commander';
import { $ } from 'execa';
import { ensureDirSync, existsSync, readJsonSync, statSync } from 'fs-extra';
import { resolve } from 'path';

const DUMP_FILENAME = '.dump.json';
const VIDEOS_FILENAME = '.videos.json';

type Playlist = {
  url: string;
  min_date: string;
  idsDescPrintSkip: string[];
  ongoing: boolean;
  accurate: boolean;
  path: string;
  maxCount: number;
  disabled: boolean;
};

let playlists: { [key: string]: Playlist } = readJsonSync("playlists.json");
for (const playlistName in playlists) {
  const playlist = playlists[playlistName];
  if (!playlist.url) throw new Error(`Missing url for playlist ${playlistName} in playlists.json`);
  if (!playlist.min_date) playlist.min_date = "1970-01-01";
  if (!playlist.idsDescPrintSkip) playlist.idsDescPrintSkip = [];
  if (!playlist.ongoing) playlist.ongoing = false;
  if (!playlist.accurate) playlist.accurate = false;
  if (!playlist.path) playlist.path = playlistName;
  if (!playlist.maxCount) playlist.maxCount = 100;
  if (!playlist.disabled) playlist.disabled = false;
  else delete playlists[playlistName];
}

async function downloadVideos() {
}

async function downloadMetadata(options: { force?: boolean }) {
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    const dumpFilepath = resolve(playlist.path, DUMP_FILENAME);
    const videosFilepath = resolve(playlist.path, VIDEOS_FILENAME);
    ensureDirSync(playlist.path);

    if (!options.force && existsSync(dumpFilepath) && existsSync(videosFilepath)) {
      const modifiedTime = statSync(videosFilepath).mtimeMs;
      console.log(modifiedTime);
    }

    if (!playlist.ongoing && existsSync(dumpFilepath) && existsSync(videosFilepath) && !options.force)
      continue;

    console.log(`Downloading metadata for ${playlistName}`);
    // const $metadata = await $({ shell: 'bash' })`yt-dlp -J --flat-playlist --extractor-args youtubetab:approximate_date ${playlist.url} > ${dumpFilepath}`;
    const x = await $`yt-dlp`;
    console.log(x);
  }
  //         if not os.path.exists(path):
  //             os.mkdir(path)

  //         if (
  //             not force
  //             and os.path.exists(dump_filepath)
  //             and os.path.exists(videos_filepath)
  //         ):
  //             modified_time = os.path.getmtime(videos_filepath)
  //             time_difference = time.time() - modified_time
  //             hours_difference = time_difference / 3600
  //             if hours_difference < 6:
  //                 continue

  //         print(f"Downloading metadata for {playlist_name}")
  //         with open(dump_filepath, "w") as f:
  //             ytdlp = subprocess.run(
  //                 [
  //                     "yt-dlp",
  //                     "-J",
  //                     "--flat-playlist",
  //                     "--extractor-args",
  //                     "youtubetab:approximate_date",
  //                     playlists[playlist_name]["url"],
  //                 ],
  //                 stdout=f,
  //                 stderr=subprocess.PIPE,
  //                 text=True,
  //             )
  //             if ytdlp.returncode != 0:
  //                 print(ytdlp.stderr)
  //                 sys.exit(ytdlp.returncode)

  //         with open(dump_filepath, "r") as f:
  //             metadata = json.loads(f.read())

  //         videos = []
  //         # atrioc_pattern = r"Streamed Live on (January|February|March|April|May|June|July|August|September|October|November|December) (\d{1,2})(?:.*?),? (\d{4})"
  //         for entry in metadata["entries"]:
  //             if playlist_name == "Atrioc":
  //                 match = re.search(atrioc_pattern, entry["description"])
  //                 if match:
  //                     month_name, day, year = match.groups()
  //                     date_object = datetime.datetime.strptime(
  //                         f"{month_name} {day} {year}", "%B %d %Y"
  //                     )
  //                 else:
  //                     if (
  //                         entry["id"]
  //                         not in playlists[playlist_name]["ids_desc_print_skip"]
  //                     ):
  //                         print(f"No date found in the description for {entry['id']}")
  //                         print(entry["description"])
  //                     date_object = datetime.datetime.fromtimestamp(entry["timestamp"])
  //             else:
  //                 if entry["timestamp"] is None:
  //                     # Private video
  //                     continue
  //                 date_object = datetime.datetime.fromtimestamp(entry["timestamp"])
  //             videos.append(
  //                 {
  //                     "id": entry["id"],
  //                     "url": entry["url"],
  //                     "title": entry["title"],
  //                     "date": date_object.strftime("%Y-%m-%d"),
  //                 }
  //             )
  //         if playlists[playlist_name]["ongoing"]:
  //             videos = sorted(videos, key=lambda x: x["date"], reverse=False)
  //         with open(videos_filepath, "w") as f:
  //             json.dump(videos, f, indent=4)


}

async function main(options: { force?: boolean }) {

}

program
  .nameFromFilename(__filename)
  .description('Download playlists listed in playlists.json')
  .option('-f, --force', 'Force metadata update');
program.command('run', { hidden: true, isDefault: true })
  .option('-f, --force', 'Force metadata update')
  .action(main);
program.command('download')
  .description('Download videos without updating metadata')
  .alias('d')
  .action(downloadVideos);
program.command('metadata')
  .description('Update metadata without downloading videos')
  .alias('m')
  .option('-f, --force', 'Force metadata update')
  .action(downloadMetadata);
program.command('bytes-per-second')
  .description('Find maximum bytes per second for a playlist')
  .alias('bps')
  .argument('[playlist]', 'Playlist to find max bps for', 'Atrioc');
program.parseAsync();

// if __name__ == "__main__":
//     if len(sys.argv) == 1:
//         main()
//     else:
//         for arg in sys.argv[1:]:
//             if arg == "download":
//                 download_videos()
//             elif arg == "metadata":
//                 download_metadata()
//             elif arg == "metadata-force":
//                 download_metadata(True)
//             elif arg == "bps":
//                 find_all_bytes_per_second()
//             elif arg == "help":
//                 print(
//                     """
// Usage:
//     index.py <commands>

// Commands:
//     download
//     metadata
//     help"""
//                 )
//             else:
//                 raise ValueError(f"Unknown argument {arg}")
