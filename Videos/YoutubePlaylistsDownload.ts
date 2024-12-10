#!/usr/bin/env -S npx tsx

import { Command, Option, program } from 'commander';
import { differenceInHours, format, isAfter, parse } from 'date-fns';
import { ensureDirSync, existsSync, readdirSync, readFileSync, readJsonSync, statfsSync, statSync, writeJsonSync } from 'fs-extra';
import { compact, padStart } from 'lodash';
import { isAbsolute, resolve } from 'path';
import { $ as $throw } from 'zx';

const $ = $throw({
  nothrow: true,
});

const DUMP_FILENAME = '.dump.json';
const VIDEOS_FILENAME = '.videos.json';
const ARCHIVE_FILENAME = '.archive';
const DOWNLOADING_FOLDER = "Downloading";
const BYTES_PER_SECOND = 463_000;
const MIN_GBS_LEFT = 2;
const MIN_HOURS_TO_UPDATE_METADATA = 6;

type Playlist = {
  url: string;
  min_date: string;
  ongoing: boolean;
  accurate: boolean;
  path: string;
  max_count: number;
  disabled: boolean;
};
type EntryThumbnail = {
  url: string;
  height: number;
  width: number;
};
type Thumbnail = EntryThumbnail & {
  preference: number;
  id: string;
  resolution: string;
};
type Entry = {
  _type: "url";
  ie_key: string;
  id: string;
  url: string;
  title: string;
  description: string;
  duration: number;
  channel_id: null;
  channel: null;
  channel_url: null;
  uploader: null;
  uploader_id: null;
  uploader_url: null;
  thumbnails: EntryThumbnail[];
  // Null when video is private
  timestamp: number | null;
  release_timestamp: null;
  availability: null;
  view_count: number | null;
  live_status: null;
  channel_is_verified: null;
  __x_forwarded_for_ip: null;
};
type Version = {
  version: string;
  current_git_head: null;
  release_git_head: string;
  repository: string;
};
type Metadata = {
  id: string;
  channel: string;
  channel_id: string;
  title: string;
  availablility: null;
  channel_follower_count: number;
  description: string;
  tags: string[];
  thumbnails: Thumbnail[];
  uploader_id: string;
  uploader_url: string;
  modified_date: null;
  view_count: number | null;
  playlist_count: number;
  uploader: string;
  channel_url: string;
  _type: "playlist";
  entries: Entry[];
  extractor_key: string;
  extractor: string;
  webpage_url: string;
  original_url: string;
  webpage_url_basename: string;
  webpage_url_domain: string;
  release_year: null;
  epoch: number;
  __files_to_move: {};
  _version: Version;
};
type Video = {
  id: string,
  url: string,
  title: string,
  date: string,
};

let playlists: { [key: string]: Playlist } = readJsonSync("playlists.json");
for (const playlistName in playlists) {
  const playlist = playlists[playlistName];
  if (!playlist.url) throw new Error(`Missing url for playlist ${playlistName} in playlists.json`);
  if (!playlist.min_date) playlist.min_date = "1970-01-01";
  if (!playlist.ongoing) playlist.ongoing = false;
  if (!playlist.accurate) playlist.accurate = false;
  if (!playlist.path) playlist.path = playlistName;
  if (!playlist.max_count) playlist.max_count = 100;
  if (!playlist.disabled) playlist.disabled = false;
  else delete playlists[playlistName];
}

function freeDiskGBs() {
  const stat = statfsSync(DOWNLOADING_FOLDER)
  return stat.bavail * stat.bsize / 1024 / 1024 / 1024;
}

function videoGBs(videoUrl: string) {
  const $ytdlp = $({ sync: true, stdio: ['ignore', 'pipe', 'ignore'] })`yt-dlp --print "%(filesize)s,%(duration)s" ${videoUrl}`;
  if ($ytdlp.exitCode !== 0) return Number.POSITIVE_INFINITY;
  const [filesizeStr, durationStr] = $ytdlp.stdout.split(',');
  let filesize = +filesizeStr;
  if (isNaN(filesize)) filesize = +durationStr * BYTES_PER_SECOND;
  if (!filesize) return Number.POSITIVE_INFINITY;
  return filesize / 1024 / 1024 / 1024;
}

async function downloadVideos() {
  ensureDirSync(DOWNLOADING_FOLDER);
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    const videos: Video[] = readJsonSync(resolve(playlist.path, VIDEOS_FILENAME));
    let printedAboutDownloadingPlaylist = false;
    let archive: string[];
    try {
      archive = readFileSync(resolve(playlist.path, ARCHIVE_FILENAME), { encoding: 'utf-8' }).split('\r?\n');
    } catch (error) {
      archive = [];
    }

    for (let i = 0; i < videos.length; i++) {
      const video = videos[i];
      const downloadCount = readdirSync(playlist.path).filter(f => f.endsWith('.mp4')).length;
      if (downloadCount >= playlist.max_count) break;
      if (video.date.localeCompare(playlist.min_date) < 0 || archive.includes(`youtube ${video.id}`)) continue;

      if (!printedAboutDownloadingPlaylist) {
        console.log(`Downloading videos for ${playlistName}`);
        printedAboutDownloadingPlaylist = true;
      }

      console.log(`Checking space for ${video.title}`);
      const diskGBs = freeDiskGBs();
      const videoSize = videoGBs(video.url);
      console.log(`${videoSize.toFixed(2)} / ${diskGBs.toFixed(2)}`)
      if (freeDiskGBs() - videoGBs(video.url) < MIN_GBS_LEFT) break;

      let outputName = "%(title)s [%(id)s].%(ext)s";
      if (playlist.ongoing) outputName = `${video.date} - ${outputName}`;
      else {
        const playlistIndex = i + 1;
        const padLength = Math.floor(Math.log10(videos.length)) + 1;
        outputName = `${padStart(playlistIndex.toString(), padLength, '0')} - ${outputName}`;
      }
      if (playlist.accurate) outputName = `%(upload_date)s ${outputName}`;

      const flags = [
        "yt-dlp",
        "-f",
        "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best",
        "--downloader",
        "aria2c",
        "--download-archive",
        isAbsolute(playlist.path) ? resolve(playlist.path, ARCHIVE_FILENAME) : resolve('..', playlist.path, ARCHIVE_FILENAME),
        "-o",
        outputName,
        video["url"],
      ];
      const $ytdlp = $({ sync: true, cwd: DOWNLOADING_FOLDER, stdio: 'inherit' })`yt-dlp ${flags}`;
      if ($ytdlp.exitCode === 0) cleanDownloadingFolder(video.id, playlist.path);
      break;
    }
    break;
  }
}



const ATRIOC_PATTERN = new RegExp("Streamed Live on (?<month>January|February|March|April|May|June|July|August|September|October|November|December) (?<date>\\d{1,2})(?:.*?),? (?<year>\\d{4})");
const ASPECTICOR_PATTERN = new RegExp("VOD from (?<month>\\w+) (?<date>\\d{1,2}), (?<year>\\d{4})");
function getVideoFromEntry(playlist: Playlist, entry: Entry): Video | undefined {
  if (!entry.timestamp) return;

  let date = new Date(entry.timestamp * 1000);
  if (playlist.url === "https://www.youtube.com/@atriocvods/videos") {
    const match = entry.description.match(ATRIOC_PATTERN);
    if (match?.groups) {
      date = parse(`${match.groups.year} ${match.groups.month} ${match.groups.date}`, "yyyy MMMM d", new Date());
    } else if (!['19j_ClWR7aA', 'v2L091WK780'].includes(entry.id)) {
      console.log(`No date found in the description for ${entry.id}`);
      console.log(entry.description);
    }
  } else if (playlist.url === "https://www.youtube.com/@aspecticorvods/videos") {
    const match = entry.description.match(ASPECTICOR_PATTERN);
    if (match?.groups) {
      date = parse(`${match.groups.year} ${match.groups.month.slice(0, 3)} ${match.groups.date}`, `yyyy MMM d`, new Date());
    } else if (isAfter(date, new Date(2023, 12, 11))) {
      console.log(`No date found in the description for ${entry.id}`);
      console.log(entry.description);
    }
  }
  return {
    id: entry.id,
    url: entry.url,
    title: entry.title,
    date: format(date, "yyyy-MM-dd"),
  };
}

async function downloadMetadata(options: { force?: boolean, video?: boolean }) {
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    const dumpFilepath = resolve(playlist.path, DUMP_FILENAME);
    const videosFilepath = resolve(playlist.path, VIDEOS_FILENAME);
    ensureDirSync(playlist.path);

    if (!options.force && existsSync(dumpFilepath) && existsSync(videosFilepath)) {
      const modifiedTime = statSync(videosFilepath).mtimeMs;
      const hours = differenceInHours(new Date(), new Date(modifiedTime));
      if (hours < MIN_HOURS_TO_UPDATE_METADATA) continue;
    }

    if (!playlist.ongoing && existsSync(dumpFilepath) && existsSync(videosFilepath) && !options.force)
      continue;

    if (!options.video || !existsSync(dumpFilepath)) {
      console.log(`Downloading metadata for ${playlistName}`);
      await $throw`yt-dlp -J --flat-playlist --extractor-args youtubetab:approximate_date "${playlist.url}" > "${dumpFilepath}.tmp"`;
      await $throw`mv "${dumpFilepath}.tmp" "${dumpFilepath}"`
    }

    const metadata: Metadata = readJsonSync(dumpFilepath);
    const videos: Video[] = compact(metadata.entries.map(e => getVideoFromEntry(playlist, e)));
    if (playlist.ongoing) videos.sort((a, b) => a.date.localeCompare(b.date));
    writeJsonSync(videosFilepath, videos, { spaces: 2 });
  }
}

async function main(options: { force?: boolean }) {
  downloadMetadata(options);
  downloadVideos()
}

async function defaultAction(options, command: Command) {
  console.log(command.name());
  console.log(options);
}

program
  .nameFromFilename(__filename)
  .description('Download playlists listed in playlists.json')
program.command('run', { hidden: true, isDefault: true })
  .option('-f, --force', 'Force metadata update')
  .action(main);
program.command('download')
  .description('Download videos without updating metadata')
  .alias('d')
  .action(downloadVideos);
program.command('metadata')
  .description('Update metadata without downloading videos')
  .option('-f, --force', 'Force metadata update')
  .addOption(new Option('-v, --video', 'Update .videos.json without updating .dump.json').implies({ force: true }))
  .alias('m')
  .action(downloadMetadata);
program.command('bytes-per-second')
  .description('Find maximum bytes per second for a playlist')
  .alias('bps')
  .argument('[playlist]', 'Playlist to find max bps for', 'Atrioc')
  .action(defaultAction);
(async () => {
  await program.parseAsync();
  console.log('Done');
})();
