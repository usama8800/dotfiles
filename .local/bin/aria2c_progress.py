#!/usr/bin/python3

import os
import re
import sys
import time

frag_file_pattern = re.compile("part-Frag\d+$")


def progressbar(it, prefix="", size=60, out=sys.stdout):  # Python3.6+
    count = len(it)
    start = time.time()  # time estimate start

    def show(j):
        x = int(size * j / count)
        # time estimate calculation and string
        remaining = ((time.time() - start) / j) * (count - j)
        mins, sec = divmod(remaining, 60)  # limited to minutes
        time_str = f"{int(mins):02}:{sec:03.1f}"
        print(
            f"{prefix}[{u'█'*x}{('.'*(size-x))}] {j}/{count} Est wait {time_str}",
            end="\r",
            file=out,
            flush=True,
        )

    show(0.1)  # avoid div/0
    for i, item in enumerate(it):
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
    width = os.get_terminal_size().columns
    heading = ""
    size = width - (
        len(heading) + 2 + 1 + len(str(urls_len)) * 2 + 1 + 1 + len("Est wait 00:00.0")
    )

    for i in progressbar(range(urls_len), heading, size):
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
