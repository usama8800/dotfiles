#!/usr/bin/env -S npx tsx

import { env as loadEnv } from '@usama8800/dotenvplus';
import { program } from 'commander';
import { ensureDirSync, existsSync, moveSync, readdirSync, readFileSync, readJsonSync, removeSync, writeFileSync } from 'fs-extra';
import { countBy } from 'lodash';
import { parse as parsePath, resolve } from 'path';
import { z } from 'zod';
import { $ as $$ } from 'zx';

enum Genre {
  'Blues' = 'Blues',
  'Classic Rock' = 'Classic Rock',
  'Country' = 'Country',
  'Dance' = 'Dance',
  'Disco' = 'Disco',
  'Funk' = 'Funk',
  'Grunge' = 'Grunge',
  'Hip-Hop' = 'Hip-Hop',
  'Jazz' = 'Jazz',
  'Metal' = 'Metal',
  'New Age' = 'New Age',
  'Oldies' = 'Oldies',
  'Other' = 'Other',
  'Pop' = 'Pop',
  'R&B' = 'R&B',
  'Rap' = 'Rap',
  'Reggae' = 'Reggae',
  'Rock' = 'Rock',
  'Techno' = 'Techno',
  'Industrial' = 'Industrial',
  'Alternative' = 'Alternative',
  'Ska' = 'Ska',
  'Death Metal' = 'Death Metal',
  'Pranks' = 'Pranks',
  'Soundtrack' = 'Soundtrack',
  'Euro-Techno' = 'Euro-Techno',
  'Ambient' = 'Ambient',
  'Trip-Hop' = 'Trip-Hop',
  'Vocal' = 'Vocal',
  'Jazz+Funk' = 'Jazz+Funk',
  'Fusion' = 'Fusion',
  'Trance' = 'Trance',
  'Classical' = 'Classical',
  'Instrumental' = 'Instrumental',
  'Acid' = 'Acid',
  'House' = 'House',
  'Game' = 'Game',
  'Sound Clip' = 'Sound Clip',
  'Gospel' = 'Gospel',
  'Noise' = 'Noise',
  'AlternRock' = 'AlternRock',
  'Bass' = 'Bass',
  'Soul' = 'Soul',
  'Punk' = 'Punk',
  'Space' = 'Space',
  'Meditative' = 'Meditative',
  'Instrumental Pop' = 'Instrumental Pop',
  'Instrumental Rock' = 'Instrumental Rock',
  'Ethnic' = 'Ethnic',
  'Gothic' = 'Gothic',
  'Darkwave' = 'Darkwave',
  'Techno-Industrial' = 'Techno-Industrial',
  'Electronic' = 'Electronic',
  'Pop-Folk' = 'Pop-Folk',
  'Eurodance' = 'Eurodance',
  'Dream' = 'Dream',
  'Southern Rock' = 'Southern Rock',
  'Comedy' = 'Comedy',
  'Cult' = 'Cult',
  'Gangsta' = 'Gangsta',
  'Top 40' = 'Top 40',
  'Christian Rap' = 'Christian Rap',
  'Pop/Funk' = 'Pop/Funk',
  'Jungle' = 'Jungle',
  'Native American' = 'Native American',
  'Cabaret' = 'Cabaret',
  'New Wave' = 'New Wave',
  'Psychadelic' = 'Psychadelic',
  'Rave' = 'Rave',
  'Showtunes' = 'Showtunes',
  'Trailer' = 'Trailer',
  'Lo-Fi' = 'Lo-Fi',
  'Tribal' = 'Tribal',
  'Acid Punk' = 'Acid Punk',
  'Acid Jazz' = 'Acid Jazz',
  'Polka' = 'Polka',
  'Retro' = 'Retro',
  'Musical' = 'Musical',
  'Rock & Roll' = 'Rock & Roll',
  'Hard Rock' = 'Hard Rock',
  'Folk' = 'Folk',
  'Folk/Rock' = 'Folk/Rock',
  'National Folk' = 'National Folk',
  'Swing' = 'Swing',
  'Fast Fusion' = 'Fast Fusion',
  'Bebob' = 'Bebob',
  'Latin' = 'Latin',
  'Revival' = 'Revival',
  'Celtic' = 'Celtic',
  'Bluegrass' = 'Bluegrass',
  'Avantgarde' = 'Avantgarde',
  'Gothic Rock' = 'Gothic Rock',
  'Progressive Rock' = 'Progressive Rock',
  'Psychedelic Rock' = 'Psychedelic Rock',
  'Symphonic Rock' = 'Symphonic Rock',
  'Slow Rock' = 'Slow Rock',
  'Big Band' = 'Big Band',
  'Chorus' = 'Chorus',
  'Easy Listening' = 'Easy Listening',
  'Acoustic' = 'Acoustic',
  'Humour' = 'Humour',
  'Speech' = 'Speech',
  'Chanson' = 'Chanson',
  'Opera' = 'Opera',
  'Chamber Music' = 'Chamber Music',
  'Sonata' = 'Sonata',
  'Symphony' = 'Symphony',
  'Booty Bass' = 'Booty Bass',
  'Primus' = 'Primus',
  'Porn Groove' = 'Porn Groove',
  'Satire' = 'Satire',
  'Slow Jam' = 'Slow Jam',
  'Club' = 'Club',
  'Tango' = 'Tango',
  'Samba' = 'Samba',
  'Folklore' = 'Folklore',
  'Ballad' = 'Ballad',
  'Power Ballad' = 'Power Ballad',
  'Rhythmic Soul' = 'Rhythmic Soul',
  'Freestyle' = 'Freestyle',
  'Duet' = 'Duet',
  'Punk Rock' = 'Punk Rock',
  'Drum Solo' = 'Drum Solo',
  'A Capella' = 'A Capella',
  'Euro-House' = 'Euro-House',
  'Dance Hall' = 'Dance Hall'
}
type TrackInfo = {
  title: string;
  artist: string;
  genre?: Genre;
  start: number;
  end?: number;
};
type Playlist = {
  videosPath: string;
  audiosPath: string;
  url: string;
  outputFormat: string;
  indices: string;
  genre?: Genre;
  trackInfo?: Record<string, TrackInfo[]>;
  disabled: boolean;
};
type EntryThumbnail = {
  url: string;
  height: number;
  width: number;
};
type Thumbnail = EntryThumbnail & {
  preference?: number;
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
  title: string;
  availablility: null;
  channel_follower_count: number;
  description: string;
  tags: string[];
  thumbnails: Thumbnail[];
  channel: string;
  channel_id: string;
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

const $throw = $$.sync;
const $ = $throw({
  nothrow: true,
});

const { VIDEOS_PATH, AUDIOS_PATH } = loadEnv<{
  VIDEOS_PATH: string;
  AUDIOS_PATH: string;
}>({
  required: ['VIDEOS_PATH', 'AUDIOS_PATH'],
});
const REMOVED_PATH = resolve(VIDEOS_PATH, 'Removed');
const ARCHIVE_FILENAME = '.archive';
const METADATA_FILENAME = '.metadata';

const secondsSchema = z.union([z.string().transform((s, ctx) => {
  const num = +s;
  if (!isNaN(num)) return num;
  const parts = s.split(":").map((p) => +p);
  if (parts.some(isNaN) || parts.length > 3 || parts.length < 2) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: "Invalid time format",
    });
    return z.NEVER;
  }
  if (parts.length === 3) return parts[0] * 60 * 60 + parts[1] * 60 + parts[2];
  return parts[0] * 60 + parts[1];
}), z.number()]);
const trackInfoSchema = z.strictObject({
  title: z.string(),
  artist: z.string(),
  genre: z.nativeEnum(Genre).optional(),
  start: secondsSchema.default(0),
  end: secondsSchema.optional(),
});
const schema = z.strictObject({
  videosPath: z.string().default(''),
  audiosPath: z.string().default(''),
  disabled: z.boolean().default(false),
  url: z.string().url(),
  outputFormat: z.string().default('%(title)s - %(id)s.%(ext)s'),
  indices: z.string().regex(/((-?\d+|-?\d*[\-:]-?\d*|-?\d*:-?\d*:-?\d*),?)+/).default(':'),
  genre: z.nativeEnum(Genre).optional(),
  trackInfo: z.record(z.string(), z.union([trackInfoSchema, trackInfoSchema.array()])).optional().transform((t) => {
    for (const id in t) {
      if (Array.isArray(t[id])) continue;
      t[id] = [t[id]];
    }
    return t as Record<string, TrackInfo[]>;
  }),
}).refine((p) => {
  // Check at least one genre is set (in playlist as a whole or per item)
  if (p.genre) return true;
  if (!p.trackInfo) return false;
  return Object.values(p.trackInfo).every((t) => t.every((ti) => ti.genre));
});

export function idFromFilename(filename: string) {
  let whole = filename.split("- ").at(-1)!.split(".")[0].trim();
  if (whole.length === 11) whole += '-0';
  return {
    id: whole.slice(0, 11),
    part: +whole.slice(12),
    whole,
  };
}

export function getDuplicateIdFiles(files: string[]): string[] {
  const ret: string[] = [];
  const idVideos: Record<string, [number[], string[]]> = {};
  for (const file of files) {
    if (file.startsWith('.') || file === 'temp.mp4') continue;
    const { id, part } = idFromFilename(file);
    if (!idVideos[id]) idVideos[id] = [[], []];
    idVideos[id][0].push(part);
    idVideos[id][1].push(file);
  }
  for (const id in idVideos) {
    const [parts, files] = idVideos[id];
    if (files.length === 1) continue;
    if (parts.includes(0)) {
      ret.push(...files);
      continue;
    }
    const partCounts = countBy(parts);
    if (Object.values(partCounts).some((c) => c > 1)) {
      ret.push(...files);
      continue;
    }
  }
  return ret;
}

export function getIncompletePartFiles(files: string[], parts: Record<string, number>): string[] {
  for (const file of files) {
    if (file.startsWith('.') || file === 'temp.mp4') continue;
    parts[idFromFilename(file).id] -= 1;
  }
  const ret: string[] = [];
  for (const file of files) {
    if (file.startsWith('.') || file === 'temp.mp4') continue;
    const { id } = idFromFilename(file);
    if (parts[id] !== 0 && !isNaN(parts[id])) ret.push(file)
  }
  return ret;
}

export function getFixedArchiveFile(archive: string[], files: string[]): string | undefined {
  if (archive.length === 0) return;
  const fileIds = files.map(idFromFilename).map(({ id }) => id);
  const archiveIds = new Set(archive.map(a => a.slice('youtube '.length)));
  let ret = '';

  for (const archiveId of archiveIds) {
    if (!archiveId) continue;
    for (const fileId of fileIds) {
      if (archiveId === fileId) {
        ret += `youtube ${archiveId}\n`;
        break;
      }
    }
  }
  return ret;
}

export function getFilesNotInMetadata(metadata: string[], files: string[]): string[] {
  if (metadata.length === 0) return [];
  const ret: string[] = [];
  for (const file of files) {
    if (file.startsWith('.')) continue;
    if (metadata.includes(idFromFilename(file).id)) continue;
    ret.push(file);
  }
  return ret;
}

type CutAction = {
  inputFile: string;
  outputFile?: string;
  start?: number;
  end?: number;
};
export function getCutActions(tracksInfo: TrackInfo[], files: string[], videosPath: string): CutAction[] {
  if (files.length === 0) return [];
  const id = idFromFilename(files[0]).id;
  const mainFile = files.find(f => idFromFilename(f).whole === `${id}-0`);
  if (tracksInfo.length === 1 && mainFile && !tracksInfo[0].start && !tracksInfo[0].end) return [];

  const onlyMainFileAvailable = files.length === 1 && mainFile;
  const allPartsAvailable = files.length === tracksInfo.length;
  const incorrectlyNumberedSingleFile = files.length === 1 && idFromFilename(files[0]).part > 0;
  let invalid = false;
  if (!onlyMainFileAvailable && (!allPartsAvailable || incorrectlyNumberedSingleFile)) invalid = true;
  if (!invalid && allPartsAvailable) {
    for (let i = 0; i < tracksInfo.length; i++) {
      const trackInfo = tracksInfo[i];
      const part = tracksInfo.length === 1 ? i : i + 1;
      const trackFile = files.find(f => idFromFilename(f).whole === `${id}-${part}`);
      if (!trackFile) {
        invalid = true;
        break;
      }
      const videoDuration = getVideoDuration(resolve(videosPath, trackFile));
      const trackDuration = getTrackDuration(trackInfo, videoDuration);
      const diff = videoDuration - trackDuration;
      if (tracksInfo.length === 1) {
        if (diff > 1) continue;
        if (diff < -1) {
          invalid = true;
          break;
        }
        return [];
      }
      if (Math.abs(diff) > 1) {
        invalid = true;
        break;
      }
    }
  }
  if (!invalid && onlyMainFileAvailable) {
    const videoDuration = getVideoDuration(resolve(videosPath, mainFile));
    const maxTrackTime = Math.max(...tracksInfo.map(t => t.end ?? 0), videoDuration);
    if (maxTrackTime > videoDuration) invalid = true;
  }
  if (invalid || (!mainFile && tracksInfo.length === 1))
    return files.map(f => ({ inputFile: f }));
  if (!mainFile) return [];

  if (tracksInfo.length === 1)
    return [{
      inputFile: mainFile!,
      outputFile: mainFile,
      start: tracksInfo[0].start,
      end: tracksInfo[0].end,
    }];
  const ret: CutAction[] = [];
  for (let i = 0; i < tracksInfo.length; i++) {
    const trackInfo = tracksInfo[i];
    ret.push({
      inputFile: mainFile,
      outputFile: parsePath(mainFile).name + `-${i + 1}.mp4`,
      start: trackInfo.start,
      end: trackInfo.end,
    });
  }
  return ret;
}

function getVideoDuration(filepath: string): number {
  if (filepath.startsWith('/test/')) return +filepath.match(/test\/(\d+)/)![1];
  const $ffprobe = $({ sync: true, stdio: ['ignore', 'pipe', 'ignore'] })`ffprobe -v error -show_streams -select_streams v:0 -of json ${filepath}`;
  const output = JSON.parse($ffprobe.stdout);
  return +output.streams[0].duration;
}

function getTrackDuration(track: TrackInfo, videoDuration: number): number {
  if (track.end) return track.end - track.start;
  return videoDuration - track.start;
}

const apRegex = new RegExp('^.*?Atom \"(.+?)\" contains: (.*)$');
function getAtomicParsleyData(filepath: string) {
  let title = '';
  let artist = '';
  let genre = '' as '' | Genre;
  const $ap = $({ sync: true, stdio: ['ignore', 'pipe', 'ignore'] })`AtomicParsley ${filepath} -t`;
  if ($ap.exitCode === 0) {
    const lines = $ap.stdout.split(/\r?\n/);
    for (const line of lines) {
      const match = line.match(apRegex);
      if (!match) continue;
      // console.log(match);
      if (match[1].endsWith('nam')) title = match[2].trim();
      else if (match[1].toLowerCase().endsWith('art')) artist = match[2].trim();
      else if (match[1] === 'gnre') genre = match[2].trim() as Genre;
    }
  }
  return { title, artist, genre };
}

function removeTempFiles() {
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    const videoFiles = readdirSync(playlist.videosPath);
    for (const file of videoFiles) {
      if (file === 'temp.mp4') {
        removeSync(resolve(playlist.videosPath, file));
      }
    }
    const audioFiles = readdirSync(playlist.audiosPath);
    for (const file of audioFiles) {
      if (file === 'temp.mp3') {
        removeSync(resolve(playlist.videosPath, file));
      }
    }
  }
}

function removeDuplicateIdFiles() {
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    const files = readdirSync(playlist.videosPath);
    const duplicates = getDuplicateIdFiles(files);
    for (const file of duplicates) {
      moveSync(resolve(playlist.videosPath, file), resolve(REMOVED_PATH, playlistName, file), { overwrite: true });
    }
  }
}

function removeIncompletePartFiles() {
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    if (!playlist.trackInfo) continue;
    const files = readdirSync(playlist.videosPath);
    const parts: Record<string, number> = {};
    for (const id in playlist.trackInfo) {
      parts[id] = playlist.trackInfo[id].length;
    }
    const incomplete = getIncompletePartFiles(files, parts);
    for (const file of incomplete) {
      removeSync(resolve(playlist.videosPath, file));
    }
  }
}

function removeArchiveIdsForDeletedFiles() {
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    if (!existsSync(resolve(playlist.videosPath, ARCHIVE_FILENAME))) continue;
    const archive = readFileSync(resolve(playlist.videosPath, ARCHIVE_FILENAME), 'utf-8').split(/(\r*\n)+/);
    const files = readdirSync(playlist.videosPath);
    const newArchive = getFixedArchiveFile(archive, files);
    if (newArchive !== undefined) writeFileSync(resolve(playlist.videosPath, ARCHIVE_FILENAME), newArchive);
  }
}

function removeFilesNotInMetadata() {
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    if (!existsSync(resolve(playlist.videosPath, METADATA_FILENAME))) continue;
    const metadata = readFileSync(resolve(playlist.videosPath, METADATA_FILENAME), 'utf-8').split(/\r?\n/);
    const files = readdirSync(playlist.videosPath);

    const toDelete = getFilesNotInMetadata(metadata, files);
    for (const file of toDelete) {
      moveSync(resolve(playlist.videosPath, file), resolve(REMOVED_PATH, playlistName, file), { overwrite: true });
    }
  }
}

function removeAudiosNotInVideos() {
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    const videoFiles = readdirSync(playlist.videosPath).map(f => parsePath(f).name);
    const audioFiles = readdirSync(playlist.audiosPath);
    for (const audioFile of audioFiles) {
      if (videoFiles.includes(parsePath(audioFile).name)) continue;
      removeSync(resolve(playlist.audiosPath, audioFile));
    }
  }
}

export function cutVideos() {
  console.log('Cutting videos');
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    if (!playlist.trackInfo) continue;
    const files = readdirSync(playlist.videosPath);
    for (const id in playlist.trackInfo) {
      const tracksInfo = playlist.trackInfo[id];
      const trackFiles = files.filter(f => idFromFilename(f).id === id);
      const cutActions = getCutActions(tracksInfo, trackFiles, playlist.videosPath);
      let cutted = false;
      for (const { inputFile, outputFile, start, end } of cutActions) {
        if (!outputFile) {
          removeSync(resolve(playlist.videosPath, inputFile));
          continue;
        }
        cutted = true;
        console.log(`Cutting ${inputFile} to ${outputFile} from ${start} to ${end}`);
        const args = ['-y', '-i', resolve(playlist.videosPath, inputFile)];
        if (start) args.push('-ss', start.toString());
        if (end) args.push('-to', end.toString());
        args.push('-c:v', 'libx264', '-c:a', 'aac', resolve(playlist.videosPath, 'temp.mp4'));
        const $ffmpeg = $({ sync: true, stdio: ['ignore', 'inherit', 'inherit'] })`ffmpeg ${args}`;
        if ($ffmpeg.exitCode !== 0) {
          console.log(`Failed to cut`);
          removeSync(resolve(playlist.videosPath, 'temp.mp4'));
          continue;
        }
        removeSync(resolve(playlist.audiosPath, parsePath(outputFile).name + '.mp3'));
        moveSync(resolve(playlist.videosPath, 'temp.mp4'), resolve(playlist.videosPath, outputFile), { overwrite: true });
      }
      if (tracksInfo.length > 1 && cutted)
        removeSync(resolve(playlist.videosPath, trackFiles.find(f => idFromFilename(f).part === 0)!));
    }
  }
}

export function tagVideos() {
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    if (!playlist.trackInfo) {
      console.log(`No track info for '${playlistName}'`);
      continue;
    }
    const files = readdirSync(playlist.videosPath);
    for (const file of files) {
      if (file.startsWith('.') || parsePath(file).ext !== '.mp4') continue;
      const { id, part } = idFromFilename(file);
      const tracksInfo = playlist.trackInfo[id];
      if (!tracksInfo) {
        console.log(`No track info for id ${id} in '${playlistName}'`);
        continue;
      }
      const trackInfo = tracksInfo[part === 0 ? 0 : part - 1];
      if (!trackInfo) {
        console.log(`No track info for part ${part} of id ${id} in '${playlistName}'`);
        continue;
      }
      const oldInfo = getAtomicParsleyData(resolve(playlist.videosPath, file));
      const args = [resolve(playlist.videosPath, file), '--overWrite'];
      if (oldInfo.title !== trackInfo.title) args.push('--title', trackInfo.title);
      if (oldInfo.artist !== trackInfo.artist) args.push('--artist', trackInfo.artist);
      const genre = trackInfo.genre ?? playlist.genre!;
      if (oldInfo.genre !== genre) args.push('--genre', genre);
      if (args.length === 2) continue;
      console.log(`Tagging ${file}`);
      const $ap = $({ sync: true, stdio: ['ignore', 'inherit', 'inherit'] })`AtomicParsley ${args}`;
      if ($ap.exitCode !== 0) {
        console.log(`Failed to tag ${file}`);
        continue;
      }
      removeSync(resolve(playlist.audiosPath, parsePath(file).name + '.mp3'));
    }
  }
}

export function convertToMp3s() {
  console.log("Converting videos to mp3s")
  for (const playlistName in playlists) {
    const playlist = playlists[playlistName];
    const files = readdirSync(playlist.videosPath);
    for (const file of files) {
      if (file.startsWith('.') || parsePath(file).ext !== '.mp4') continue;
      const outputFilepath = resolve(playlist.audiosPath, parsePath(file).name + '.mp3');
      if (existsSync(outputFilepath)) continue;
      console.log(`Converting ${file} to mp3`);
      const $ffmpeg = $({ sync: true, stdio: ['ignore', 'ignore', 'ignore'] })`ffmpeg -y -i ${resolve(playlist.videosPath, file)} -codec:a libmp3lame -qscale:a 0 temp.mp3`;
      if ($ffmpeg.exitCode !== 0) {
        console.log(`Failed to convert ${file}`);
        continue;
      }
      moveSync('temp.mp3', outputFilepath, { overwrite: true });
    }
  }
}

export function downloadVideos() {
  for (const playlistName in playlists) {
    console.log(`Downloading playlist '${playlistName}'`);
    const playlist = playlists[playlistName];
    $({ sync: true, stdio: ['ignore', 'inherit', 'inherit'] })`yt-dlp -f 'bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best/bestvideo+bestaudio' --no-mtime --playlist-items ${playlist.indices} -o ${resolve(playlist.videosPath, playlist.outputFormat)} --download-archive ${resolve(playlist.videosPath, ARCHIVE_FILENAME)} ${playlist.url}`;
  }
}

export function downloadMetadata() {
  for (const playlistName in playlists) {
    console.log(`Downloading metadata for '${playlistName}'`);
    const playlist = playlists[playlistName];
    const $ytdlp = $({ sync: true, stdio: ['ignore', 'pipe', 'pipe'] })`yt-dlp --playlist-items ${playlist.indices} -J --flat-playlist ${playlist.url}`;
    if ($ytdlp.exitCode !== 0) {
      console.error($ytdlp.stderr);
      continue;
    }
    const metadata = JSON.parse($ytdlp.stdout);
    writeFileSync(resolve(playlist.videosPath, METADATA_FILENAME), metadata.entries.map((e) => e.id).join('\n'));
  }
}

export function clean() {
  removeTempFiles();
  removeDuplicateIdFiles();
  removeIncompletePartFiles();
  removeArchiveIdsForDeletedFiles();
  removeFilesNotInMetadata();
  removeAudiosNotInVideos();
}

export function main() {
  // console.log(existsSync(resolve('Videos', 'Best Classics', `Prokofiev - Romeo and Juliet, No. 13 Dance of the Knights (Mariinsky Orchestra, Valery Gergiev) - s_9Uw9bCM30.mp4`)));
  removeTempFiles();
  removeDuplicateIdFiles();
  removeIncompletePartFiles();
  removeArchiveIdsForDeletedFiles();

  downloadVideos();
  downloadMetadata();

  removeDuplicateIdFiles();
  removeFilesNotInMetadata();

  cutVideos();
  tagVideos();
  convertToMp3s();

  removeAudiosNotInVideos();
  removeTempFiles();
}

let playlists: { [key: string]: Playlist };
if (require.main === module) {
  ensureDirSync(VIDEOS_PATH);
  ensureDirSync(AUDIOS_PATH);
  ensureDirSync(REMOVED_PATH);
  playlists = readJsonSync("playlists.json");
  for (const playlistName in playlists) {
    const parsed = schema.parse(playlists[playlistName]);
    parsed.videosPath = parsed.videosPath || resolve(VIDEOS_PATH, playlistName);
    parsed.audiosPath = parsed.audiosPath || resolve(AUDIOS_PATH, playlistName);
    if (parsed.disabled) delete playlists[playlistName]
    else playlists[playlistName] = parsed;

    ensureDirSync(parsed.videosPath);
    ensureDirSync(parsed.audiosPath);
    ensureDirSync(resolve(REMOVED_PATH, playlistName));
  }

  program
    .nameFromFilename(__filename)
    .description('Download playlists listed in playlists.json')
  program.command('run', { hidden: true, isDefault: true })
    .action(main);
  program.command('download')
    .description('Download videos')
    .alias('d')
    .action(downloadVideos);
  program.command('metadata')
    .description('Update metadata')
    .alias('m')
    .action(downloadMetadata);
  program.command('cut')
    .description('Cut videos')
    .action(cutVideos);
  program.command('convert')
    .description('Convert videos to mp3s')
    .alias('conv')
    .action(convertToMp3s);
  program.command('tag')
    .description('Tag videos')
    .action(tagVideos);
  program.command('clean')
    .description('Delete unwanted files')
    .action(clean);
  program.parse();
}
