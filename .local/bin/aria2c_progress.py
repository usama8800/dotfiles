#!/usr/bin/python3

import os
import re
import sys
import time

frag_file_pattern = re.compile("part-Frag\d+$")


def progressbar(it, prefix="", given_size=0, out=sys.stdout, skipped=0):  # Python3.6+
    count = len(it)
    start = time.time()  # time estimate start

    def show(j):
        remaining = ((time.time() - start) / (j - skipped)) * (count - (j - skipped))
        mins, sec = divmod(remaining, 60)
        hrs, mins = divmod(mins, 60)
        time_str = f"{int(mins):02}:{int(sec):02}"
        if hrs > 0:
            time_str = f"{int(hrs):02}:{time_str}"

        replace_str = "progress_bar_goes_here"
        msg = f"{prefix}[{replace_str}] {j}/{count} - ETA {time_str}"
        size = (
            given_size
            if given_size > 0
            else os.get_terminal_size().columns - (len(msg) - len(replace_str))
        )
        progress = int(size * j / count)
        print(
            msg.replace(replace_str, f"{u'█' * progress}{('.' * (size - progress))}"),
            end="\r",
            file=out,
            flush=True,
        )

    show(skipped - 1 if skipped > 1 else 0.1)
    for i, item in enumerate(it):
        if i < skipped:
            continue
        yield item
        show(i + 1)
    print("\n", file=out, flush=True)


def get_fragments_len():
    files = os.listdir(".")
    return len(list(filter(lambda x: frag_file_pattern.search(x), files)))


def get_urls_len():
    files = os.listdir(".")
    url_file = filter(lambda x: x.endswith(".frag.urls"), files)
    url_file = list(url_file)
    if len(url_file) == 0:
        print("No urls found")
        return
    url_file = url_file[0]
    with open(url_file) as f:
        urls_len = f.readlines()
        return len(
            list(
                filter(
                    lambda x: x.startswith("out="), map(lambda x: x.strip(), urls_len)
                )
            )
        )


def main():
    urls_len = get_urls_len()
    frags_len = get_fragments_len()
    for i in progressbar(range(urls_len), skipped=frags_len):
        if i < frags_len:
            continue
        while True:
            time.sleep(1)
            new_frags_len = get_fragments_len()
            if new_frags_len > frags_len:
                frags_len = new_frags_len
                break


if __name__ == "__main__":
    if len(sys.argv) == 1:
        main()
    else:
        for arg in sys.argv[1:]:
            if arg == "help":
                print()
            else:
                raise ValueError(f"Unknown argument {arg}")
