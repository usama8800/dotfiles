#!/usr/bin/env python3

import os
import shutil
import string
import urllib.request
from concurrent import futures
from itertools import repeat

import requests
from lxml import html

TIMEOUT = 10_000
MAX_RETRIES = 2
PATH = "Wallpapers/Wasyl"
urls = {
    "Daydream": "https://wasylart.com/gallery/souls/daydream/",
    "Vision": "https://wasylart.com/gallery/souls/vision/",
    "Ether": "https://wasylart.com/gallery/souls/ether/",
    "Neon": "https://wasylart.com/gallery/souls/neon/",
    "Unicorn Tail": "https://wasylart.com/gallery/souls/unicorn-tail/",
    "Plasmosphere": "https://wasylart.com/gallery/bodies/slime/",
    "Glitter": "https://wasylart.com/gallery/bodies/glitter/",
    "Holi": "https://wasylart.com/gallery/bodies/holi-zywe-plotno/",
    "UV Mattery": "https://wasylart.com/gallery/bodies/uv-mattery/",
    "Bodypainting": "https://wasylart.com/gallery/bodies/bodypainting/",
    "Eros": "https://wasylart.com/gallery/intimacy/eros/",
    "Shibari": "https://wasylart.com/gallery/intimacy/shibari/",
    "Down": "https://wasylart.com/gallery/intimacy/puch/",
    "Carnality": "https://wasylart.com/gallery/intimacy/cielesnosc/",
}
ignore_list = []
banned_chars = ["/\\|"]


def fix_filename(name: str):
    return "".join(
        [c for c in name if ord(c) >= 0x20 and ord(c) <= 0x7E and c not in banned_chars]
    )


def download_image_by_url(album, url):
    url_path = urllib.request.urlparse(url).path
    noext, ext = os.path.splitext(url_path)
    title = os.path.basename(noext)
    path = os.path.join(PATH, album)
    filename = os.path.join(path, fix_filename(title + ext))

    if not os.path.exists(path):
        os.makedirs(path, exist_ok=True)

    if os.path.exists(filename):
        return {
            "status": "Old",
            "image_url": url,
        }

    download_status = False
    try:
        temp, headers = urllib.request.urlretrieve(url)
        print(1)
        shutil.move(temp, filename)
        print(2)
        download_status = True
    except Exception as e:
        print(filename)
        print(e.with_traceback())
    finally:
        return {
            "status": download_status,
            "image_url": url,
        }


def extract_image_urls(url, request_try=0):
    if request_try - 1 == MAX_RETRIES:
        raise Exception("You Have Reach The Maximum Request")
    try:
        response = requests.get(url, timeout=TIMEOUT)
    except requests.exceptions.RequestException as e:
        print("Url Request Failed", e)
        extract_image_urls(url, request_try + 1)

    if response.status_code != 200:
        raise Exception(f"HTTP Error {response.status_code} for {url}")
    response_in_html = html.fromstring(response.text)

    a_list = response_in_html.xpath("//a/@href")
    a_list = list(filter(lambda x: x.endswith(".jpg"), a_list))

    return a_list


def download_all_images(album, url):
    print(album)
    image_url_list = extract_image_urls(url)

    with futures.ThreadPoolExecutor() as executor:
        results = executor.map(
            download_image_by_url,
            [album] * len(image_url_list),
            image_url_list,
        )

        for result, i in zip(results, range(1, len(image_url_list) + 1)):
            if result["status"] == True:
                print(
                    f"🟢 ({i/len(image_url_list)*100:.02f}%) download success: {result['image_url']}"
                )
            elif result["status"] == "Old":
                # print(
                #     f"🔵 ({i/len(image_url_list)*100:.02f}%) already downloaded: {result['image_url']}"
                # )
                pass
            else:
                print(f"🔴 download failed: {result['image_url']}")


if __name__ == "__main__":
    # for album in urls:
    #     download_all_images(album, urls[album])
    ret = download_image_by_url(
        "Daydream",
        "https://wasylart.com/wp-content/uploads/2021/02/P1610013-Edit-Edit-_-—-2048.jpg",
    )
    print(ret)
