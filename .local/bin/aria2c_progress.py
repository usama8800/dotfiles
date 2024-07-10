#!/usr/bin/python3

import os
import re
import sys
import time

frag_file_pattern = re.compile("part-Frag\d+$")


def progressbar(it, prefix="", given_size=0, out=sys.stdout, skipped=0):  # Python3.6+
    count = len(it)
    start = time.time()  # time estimate start
    skipped_percentage = skipped / count

    def show(j):
        percentage = j / count
        time_spent = time.time() - start
        expected_total_time = time_spent / (percentage - skipped_percentage)
        time_remaining = expected_total_time * (1 - percentage)
        mins, sec = divmod(time_remaining, 60)
        hrs, mins = divmod(mins, 60)
        time_str = f"{int(mins):02}:{int(sec):02}"
        if hrs > 99:
            time_str = f"{int(hrs)}:{time_str}"
        elif hrs > 0:
            time_str = f"{int(hrs)}:{time_str}"

        percentage_str = f"{percentage*100:.2f}%"
        replace_str = "progress_bar_goes_here"
        msg = f"{prefix}[{replace_str}] {percentage_str} - ETA {time_str}"
        size = (
            given_size
            if given_size > 0
            else os.get_terminal_size().columns - (len(msg) - len(replace_str))
        )
        progress_size = int(size * percentage)
        print(
            msg.replace(
                replace_str, f"{u'█' * progress_size}{('.' * (size - progress_size))}"
            ),
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
        print("No urls file found")
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
    if urls_len is None:
        return
    if frags_len is None:
        frags_len = 0
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
