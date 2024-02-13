#!/bin/bash
# https://www.gnu.org/software/bash/manual/html_node/index.html

# Template based on the one provided by Thibaut Rousseau
# from https://dev.to/thiht/shell-scripts-matter
set -euo pipefail
IFS=$'\n\t'

LOG_FILE="/tmp/$(basename "$0").log"
readonly LOG_FILE
info()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $*" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

declare -A PLAYLISTS=(
    ["Random Music"]="https://www.youtube.com/playlist?list=PLZY56D5QXJZ_WyaiL6BlA7dV2UiwZOzzn"
    ["Down with the Atriarchy"]="https://www.youtube.com/playlist?list=PLnnmg4FEileQGTodcPMvqYo79LtTZVpDV"
    ["Best Classics"]="https://www.youtube.com/playlist?list=PLZY56D5QXJZ9IISu_gzegHwZURZYFQc8z"
)
declare -A OUTPUT_FORMATS=(
    ["Down with the Atriarchy"]="Down with the Atriarchy/%(playlist_index)02d - %(title)s - %(id)s.%(ext)s"
)
declare -A ITEMS=(
    ["Down with the Atriarchy"]="2-4,6-12,14-16,18-24,26,28,30"
)

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    ./PrePostYTDLP.py
    for playlist in "${!PLAYLISTS[@]}"; do
        url="${PLAYLISTS[$playlist]}"
        output_format="${OUTPUT_FORMATS[$playlist]:-$playlist/%(title)s - %(id)s.%(ext)s}"
        items="${ITEMS[$playlist]:-:}"
        echo "Downloading playlist '$playlist' from '$url' with output format '$output_format' and items '$items'"
        options=(
            -f "bestvideo[height<=1080][ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best"
            --no-mtime
            --playlist-items "$items"
            -o "$output_format"
            --download-archive "./$playlist/.archive"
            "$url"
        )
        yt-dlp "${options[@]}"
        yt-dlp --playlist-items "$items" "$url" -J --flat-playlist | jq -r '.entries[] | .id' > "./$playlist/.metadata"
    done
    ./PrePostYTDLP.py
fi
