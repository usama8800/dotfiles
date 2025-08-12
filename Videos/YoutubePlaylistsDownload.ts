#!/usr/bin/env -S npx tsx

import { Option, program } from 'commander';
import { differenceInHours, format } from 'date-fns';
import { ensureDirSync, existsSync, moveSync, readdirSync, readFileSync, readJsonSync, rmSync, statfsSync, statSync, writeJsonSync } from 'fs-extra';
import { compact, padStart } from 'lodash';
import { resolve } from 'path';
import { z } from 'zod';
import { $ } from 'zx';
import { playlists as inputPlaylists } from './playlists';
import { Entry, Metadata, Playlist, Video } from './utils';

const DUMP_FILENAME = '.dump.json';
const VIDEOS_FILENAME = '.videos.json';
const ARCHIVE_FILENAME = '.archive';
const DOWNLOADING_FOLDER = 'Downloading';
const BYTES_PER_SECOND = 566_000;
const MIN_GBS_LEFT = 2;
const MIN_HOURS_TO_UPDATE_METADATA = 6;

const playlists = inputPlaylists as Record<string, Playlist>;
const schema = z.strictObject({
  url: z.string().url(),
  min_date: z.string().date().default('1970-01-01'),
  ongoing: z.boolean().default(false),
  accurate: z.boolean().default(false),
  path: z.string().default(''),
  max_count: z.number().int().positive().default(100),
  disabled: z.boolean().default(false),
  getEntry: z.function(z.tuple([z.any()]), z.any()).optional(),
});
for (const playlistName in playlists) {
  const parsed = schema.parse(playlists[playlistName]);
  parsed.path = parsed.path || playlistName;
  if (parsed.disabled) delete playlists[playlistName];
  else playlists[playlistName] = parsed;
}

function freeDiskGBs() {
  const stat = statfsSync(DOWNLOADING_FOLDER);
  return stat.bavail * stat.bsize / 1024 / 1024 / 1024;
}

function fileGBs(path: string) {
  const stat = statSync(path);
  if (stat.isFile()) return stat.size / 1024 / 1024 / 1024;
  const files = readdirSync(path);
  let size = 0;
  for (const file of files) {
    size += fileGBs(resolve(path, file));
  }
  return size;
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

function downloadVideos(skipSizeCheck = false) {
  ensureDirSync(DOWNLOADING_FOLDER);
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    const videos: Video[] = readJsonSync(resolve(playlist.path, VIDEOS_FILENAME));
    let printedAboutDownloadingPlaylist = false;
    let archive: string[];
    try {
      archive = readFileSync(resolve(playlist.path, ARCHIVE_FILENAME), { encoding: 'utf-8' }).split(/\r?\n/);
    } catch (error) {
      archive = [];
    }

    for (let i = 0; i < videos.length; i++) {
      const video = videos[i];
      const downloadCount = readdirSync(playlist.path).filter(f => isFileVideo(f)).length;
      if (downloadCount >= playlist.max_count) break;
      if (video.date.localeCompare(playlist.min_date) < 0 || archive.includes(`youtube ${video.id}`)) continue;

      if (!printedAboutDownloadingPlaylist) {
        console.log(`Downloading videos for ${playlistName}`);
        printedAboutDownloadingPlaylist = true;
      }

      if (!skipSizeCheck) {
        console.log(`Checking space for ${video.title}`);
        const diskGBs = freeDiskGBs();
        const videoSize = videoGBs(video.url);
        const downloadingFolderSize = fileGBs(DOWNLOADING_FOLDER);
        console.log(`(${videoSize.toFixed(2)} * 2) / (${diskGBs.toFixed(2)} + ${downloadingFolderSize.toFixed(2)})`);
        if (diskGBs + downloadingFolderSize - videoSize * 2 < MIN_GBS_LEFT) break;
      }

      let outputName = '%(title)s [%(id)s].%(ext)s';
      if (playlist.ongoing) outputName = `${video.date} - ${outputName}`;
      else {
        const playlistIndex = i + 1;
        const padLength = Math.floor(Math.log10(videos.length)) + 1;
        outputName = `${padStart(playlistIndex.toString(), padLength, '0')} - ${outputName}`;
      }
      if (playlist.accurate) outputName = `%(upload_date)s ${outputName}`;

      const flags = [
        '-f',
        'bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best/bestvideo+bestaudio',
        '--downloader',
        'aria2c',
        '--download-archive',
        resolve(playlist.path, ARCHIVE_FILENAME),
        '-o',
        outputName,
        video['url'],
      ];
      const $ytdlp = $({ sync: true, cwd: DOWNLOADING_FOLDER, stdio: 'inherit' })`yt-dlp ${flags}`;
      if ($ytdlp.exitCode === 0) cleanDownloadingFolder(video.id, playlist.path);
    }
  }
}

function cleanDownloadingFolder(id: string, copyToDir: string) {
  const files = readdirSync(DOWNLOADING_FOLDER);
  for (const file of files) {
    if (file.indexOf(`[${id}]`) === -1) continue;
    if (isFileVideo(file)) {
      const bps = videoBPS(resolve(DOWNLOADING_FOLDER, file));
      if (bps > BYTES_PER_SECOND) {
        console.log(`NEW LARGEST BYTES PER SECOND: ${bps}`);
      }
      moveSync(resolve(DOWNLOADING_FOLDER, file), resolve(copyToDir, file));
    } else {
      rmSync(resolve(DOWNLOADING_FOLDER, file));
    }
  }
}

function printAllBPS(playlistName: string) {
  const bpss = [] as number[];
  const files = readdirSync(playlists[playlistName].path);
  for (const file of files) {
    if (!isFileVideo(file) || file.startsWith('.')) continue;
    bpss.push(videoBPS(resolve(playlists[playlistName].path, file)));
  }
  bpss.sort((a, b) => b - a);
  console.log(bpss.map(x => Math.floor(x)).join('\n'));
}

function videoBPS(filepath: string) {
  const $ffprobe = $({ sync: true, stdio: ['ignore', 'pipe', 'inherit'] })`ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 ${filepath}`;
  const duration = +$ffprobe.stdout;
  const filesize = statSync(filepath).size;
  return filesize / duration;
}

function isFileVideo(filepath: string) {
  return filepath.endsWith('.mp4') || filepath.endsWith('.webm');
}

function getVideoFromEntry(playlist: Playlist, entry: Entry): Video | undefined {
  if (!entry.timestamp) return;

  let date = new Date(entry.timestamp * 1000);
  let title = entry.title;
  if (playlist.getEntry) {
    const data = playlist.getEntry(entry);
    if (data === null) {
      return;
    } else {
      if (data?.date) date = data.date;
      if (data?.title) title = data.title;
    }
  }
  return {
    id: entry.id,
    url: entry.url,
    date: format(date, 'yyyy-MM-dd'),
    title,
  };
}

function downloadMetadata(options: { force?: boolean, video?: boolean, skipSizeCheck: boolean }) {
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
      const tmpDumpFilepath = `${dumpFilepath}.tmp`;
      $({ sync: true })`yt-dlp -J --flat-playlist --extractor-args youtubetab:approximate_date ${playlist.url} > ${tmpDumpFilepath}`;
      moveSync(tmpDumpFilepath, dumpFilepath, { overwrite: true });
    }

    const metadata: Metadata = readJsonSync(dumpFilepath);
    const videos: Video[] = compact(metadata.entries.map(e => getVideoFromEntry(playlist, e)));
    if (playlist.ongoing) videos.sort((a, b) => a.date.localeCompare(b.date));
    writeJsonSync(videosFilepath, videos, { spaces: 2 });
  }
}

function main(options: { force?: boolean, skipSizeCheck: boolean }) {
  downloadMetadata(options);
  downloadVideos(options.skipSizeCheck);
}

program
  .nameFromFilename(__filename)
  .description('Download playlists listed in playlists.json');
program.command('run', { hidden: true, isDefault: true })
  .option('-f, --force', 'Force metadata update')
  .option('-s, --skip-size-check', 'Skip size check', false)
  .option('-p, --playlist <playlist_name>', 'S')
  .action(main);
program.command('download')
  .description('Download videos without updating metadata')
  .alias('d')
  .option('-s, --skip-size-check', 'Skip size check', false)
  .action(downloadVideos);
program.command('metadata')
  .description('Update metadata without downloading videos')
  .option('-f, --force', 'Force metadata update')
  .option('-s, --skip-size-check', 'Skip size check', false)
  .addOption(new Option('-v, --video', 'Update .videos.json without updating .dump.json').implies({ force: true }))
  .alias('m')
  .action(downloadMetadata);
program.command('bytes-per-second')
  .description('Find maximum bytes per second for a playlist')
  .alias('bps')
  .argument('[playlist-name]', 'Playlist to find max bps for', Object.keys(playlists)[0])
  .action(printAllBPS);
program.parse();
