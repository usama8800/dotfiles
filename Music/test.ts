import { expect } from "chai";
import { getCutActions, getDuplicateIdFiles, getFilesNotInMetadata, getFixedArchiveFile, getIncompletePartFiles, idFromFilename } from "./YoutubePlaylistsDownload";

function generateRandomId(length: number = 11): string {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
  let result = '';

  for (let i = 0; i < length; i++) {
    const randomIndex = Math.floor(Math.random() * characters.length);
    result += characters.charAt(randomIndex);
  }

  return result;
}

describe('id from filename', () => {
  it('normal id', () => {
    const id1 = generateRandomId();
    const { id, part, whole } = idFromFilename(`Video name - ${id1}.mp4`);
    expect(id).to.equal(id1);
    expect(part).to.equal(0);
    expect(whole).to.equal(id1 + '-0');
  });

  it('id with part', () => {
    const ans = generateRandomId();
    const { id, part, whole } = idFromFilename(`Video name - ${ans}-1.mp4`);
    expect(id).to.equal(ans);
    expect(part).to.equal(1);
    expect(whole).to.equal(`${ans}-1`);
  })
});

describe('get incomplete part files', () => {
  it('no incomplete parts', () => {
    const id1 = generateRandomId();
    const id2 = generateRandomId();
    const files = [`a - ${id1}.mp4`, `b - ${id2}.mp4`];
    const incomplete = getIncompletePartFiles(files, { [id1]: 1, [id2]: 1 });
    expect(incomplete.length).to.equal(0);
  });

  it('incomplete parts', () => {
    const id1 = generateRandomId();
    const id2 = generateRandomId();
    const files = [`a - ${id1}-1.mp4`, `b - ${id1}-2.mp4`, `c - ${id2}.mp4`];
    const incomplete = getIncompletePartFiles(files, { [id1]: 3, [id2]: 1 });
    expect(incomplete.length).to.equal(2);
  });

  it('id not in track info', () => {
    const files = [`a - ${generateRandomId()}.mp4`];
    const incomplete = getIncompletePartFiles(files, {});
    expect(incomplete.length).to.equal(0);
  });
});

describe('get duplicate id files', () => {
  it('no duplicates without parts', () => {
    const dups = getDuplicateIdFiles([`a - ${generateRandomId()}.mp4`, `b - ${generateRandomId()}.mp4`]);
    expect(dups.length).to.equal(0);
  })
  it('no duplicates with parts', () => {
    const id = generateRandomId();
    const dups = getDuplicateIdFiles([`a - ${id}-1.mp4`, `b - ${id}-2.mp4`]);
    expect(dups.length).to.equal(0);
  })

  it('duplicate without parts', () => {
    const sameId = generateRandomId();
    const dups = getDuplicateIdFiles([`a - ${sameId}.mp4`, `b - ${sameId}.mp4`]);
    expect(dups.length).to.equal(2);
  });

  it('duplicate with parts', () => {
    const sameId = generateRandomId();
    const dups = getDuplicateIdFiles([`a - ${sameId}-1.mp4`, `b - ${sameId}-1.mp4`]);
    expect(dups.length).to.equal(2);
  });

  it('duplicate with parts and part 0', () => {
    const sameId = generateRandomId();
    const dups = getDuplicateIdFiles([`a - ${sameId}.mp4`, `b - ${sameId}-1.mp4`, `c - ${sameId}-2.mp4`]);
    expect(dups.length).to.equal(3);
  });
});

describe('get fixed archive file', () => {
  it('updated archive file without parts', () => {
    const id1 = generateRandomId();
    const id2 = generateRandomId();
    const archive = [`youtube ${id1}`, `youtube ${id2}`];
    const files = [`a - ${id1}.mp4`, `b - ${id2}.mp4`];
    const newArchive = getFixedArchiveFile(archive, files);
    expect(newArchive).to.equal(archive.join('\n'));
  });

  it('updated archive file with parts', () => {
    const id1 = generateRandomId();
    const id2 = generateRandomId();
    const archive = [`youtube ${id1}`, `youtube ${id2}`];
    const files = [`a - ${id1}-1.mp4`, `b - ${id1}-2.mp4`, `c - ${id2}.mp4`];
    const newArchive = getFixedArchiveFile(archive, files);
    expect(newArchive).to.equal(archive.join('\n'));
  });

  it('extra id in archive', () => {
    const id1 = generateRandomId();
    const id2 = generateRandomId();
    const archive = [`youtube ${id1}`, `youtube ${id2}`, `youtube ${generateRandomId()}`];
    const files = [`a - ${id1}.mp4`, `b - ${id2}.mp4`];
    const newArchive = getFixedArchiveFile(archive, files);
    expect(newArchive).to.equal(archive.slice(0, 2).join('\n'));
  });
});

describe('get files not in metadata', () => {
  it('no extra file without parts', () => {
    const id1 = generateRandomId();
    const id2 = generateRandomId();
    const metadata = [id1, id2];
    const files = [`a - ${id1}.mp4`, `b - ${id2}.mp4`];
    const extra = getFilesNotInMetadata(metadata, files);
    expect(extra.length).to.equal(0);
  });

  it('no extra file with parts', () => {
    const id1 = generateRandomId();
    const id2 = generateRandomId();
    const metadata = [id1, id2];
    const files = [`a - ${id1}-1.mp4`, `b - ${id1}-2.mp4`, `c - ${id2}.mp4`];
    const extra = getFilesNotInMetadata(metadata, files);
    expect(extra.length).to.equal(0);
  });

  it('extra files with and without parts', () => {
    const id1 = generateRandomId();
    const id2 = generateRandomId();
    const id3 = generateRandomId();
    const metadata = [id1];
    const files = [`a - ${id1}.mp4`, `b - ${id2}-1.mp4`, `c - ${id2}-2.mp4`, `d - ${id3}.mp4`];
    const extra = getFilesNotInMetadata(metadata, files);
    expect(extra.length).to.equal(3);
  });
});

describe('get cut actions', () => {
  it('one part, uncut correct', () => {
    const id = generateRandomId();
    const actions = getCutActions([{ artist: 'Artist', title: 'Title', start: 0 }], [`10 - ${id}.mp4`], '/test/');
    expect(actions.length).to.equal(0);
  });

  it('one part, cut correct length', () => {
    const id = generateRandomId();
    const actions = getCutActions([{ artist: 'Artist', title: 'Title', start: 10, end: 20 }], [`10 - ${id}.mp4`], '/test/');
    expect(actions.length).to.equal(0);
  });

  it('one part, length too short', () => {
    const id = generateRandomId();
    const file = `10 - ${id}.mp4`;
    const actions = getCutActions([{ artist: 'Artist', title: 'Title', start: 0, end: 20 }], [file], '/test/');
    expect(actions.length).to.equal(1);
    expect(actions[0].inputFile).to.equal(file);
    expect(actions[0].outputFile).to.be.undefined;
    expect(actions[0].start).to.be.undefined;
    expect(actions[0].end).to.be.undefined;
  });

  it('one part, length too big', () => {
    const id = generateRandomId();
    const file = `100 - ${id}.mp4`;
    const actions = getCutActions([{ artist: 'Artist', title: 'Title', start: 10, end: 20 }], [file], '/test/');
    expect(actions.length).to.equal(1);
    expect(actions[0].inputFile).to.equal(file);
    expect(actions[0].outputFile).to.equal(file);
    expect(actions[0].start).to.equal(10);
    expect(actions[0].end).to.equal(20);
  });

  it('one part, numbered', () => {
    const id = generateRandomId();
    const file = `100 - ${id}-1.mp4`;
    const actions = getCutActions([{ artist: 'Artist', title: 'Title', start: 0 }], [file], '/test/');
    expect(actions.length).to.equal(1);
    expect(actions[0].inputFile).to.equal(file);
    expect(actions[0].outputFile).to.be.undefined;
  });

  it('multiple parts, found only main', () => {
    const id = generateRandomId();
    const file = `20 - ${id}.mp4`;
    const actions = getCutActions([
      { artist: 'Artist 1', title: 'Cut 1', start: 0, end: 10 },
      { artist: 'Artist 2', title: 'Cut 2', start: 10, end: 20 },
    ], [file], '/test/');
    expect(actions.length).to.equal(2);
    expect(actions[0].inputFile).to.equal(file);
    expect(actions[0].outputFile).to.equal(`20 - ${id}-1.mp4`);
    expect(actions[0].start).to.equal(0);
    expect(actions[0].end).to.equal(10);
    expect(actions[1].inputFile).to.equal(file);
    expect(actions[1].outputFile).to.equal(`20 - ${id}-2.mp4`);
    expect(actions[1].start).to.equal(10);
    expect(actions[1].end).to.equal(20);
  });

  it('multiple parts, all found, correct length', () => {
    const id = generateRandomId();
    const files = [`10 - ${id}-1.mp4`, `10 - ${id}-2.mp4`];
    const actions = getCutActions([
      { artist: 'Artist 1', title: 'Cut 1', start: 0, end: 10 },
      { artist: 'Artist 2', title: 'Cut 2', start: 10, end: 20 },
    ], files, '/test/');
    expect(actions.length).to.equal(0);
  });

  it('multiple parts, all found, incorrect length', () => {
    const id = generateRandomId();
    const files = [`20 - ${id}-1.mp4`, `20 - ${id}-2.mp4`];
    const actions = getCutActions([
      { artist: 'Artist 1', title: 'Cut 1', start: 0, end: 10 },
      { artist: 'Artist 2', title: 'Cut 2', start: 10, end: 20 },
    ], files, '/test/');
    expect(actions.length).to.equal(2);
    expect(actions[0].inputFile).to.equal(files[0]);
    expect(actions[0].outputFile).to.be.undefined;
    expect(actions[1].inputFile).to.equal(files[1]);
    expect(actions[1].outputFile).to.be.undefined;
  });

  it('multiple parts, less found', () => {
    const id = generateRandomId();
    const files = [`10 - ${id}-1.mp4`];
    const actions = getCutActions([
      { artist: 'Artist 1', title: 'Cut 1', start: 0, end: 10 },
      { artist: 'Artist 2', title: 'Cut 2', start: 10, end: 20 },
    ], files, '/test/');
    expect(actions.length).to.equal(1);
    expect(actions[0].inputFile).to.equal(files[0]);
    expect(actions[0].outputFile).to.be.undefined;
  });

  it('multiple parts, more found', () => {
    const id = generateRandomId();
    const files = [`10 - ${id}-1.mp4`, `10 - ${id}-2.mp4`];
    const actions = getCutActions([
      { artist: 'Artist 1', title: 'Cut 1', start: 0, end: 10 },
    ], files, '/test/');
    expect(actions.length).to.equal(2);
    expect(actions[0].inputFile).to.equal(files[0]);
    expect(actions[0].outputFile).to.be.undefined;
    expect(actions[1].inputFile).to.equal(files[1]);
    expect(actions[1].outputFile).to.be.undefined;
  });
});
