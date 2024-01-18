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

# Argument Parsing
USAGE="Usage:  ${CMD:=${0##*/}} [(-v|--verbose)] [--name=TEXT] [(-o|--output) FILE] [ARGS...]"
#/ Description:
#/ Examples:
#/ Options:
#/   -h, --help: Display this help message
help() {
    echo "$USAGE"
    grep '^#/' "$0" | cut -c4-
    exit 0
}
exit2 () {
    printf >&2 "%s:  %s: '%s'\n%s\n" "$CMD" "$1" "$2" "$USAGE"
    exit 2
}
check () { # avoid infinite loop
    { [ "$1" != "$EOL" ] && [ "$1" != '--' ]; } || exit2 "missing argument" "$2"
}

# parse command-line options
set -- "$@" "${EOL:=$(printf '\1\3\3\7')}"  # end-of-list marker
while [ "$1" != "$EOL" ]; do
  opt="$1"; shift
  case "$opt" in

    #EDIT HERE: defined options
         --name    ) check "$1" "$opt"; opt_name="$1"; shift;;
    -o | --output  ) check "$1" "$opt"; opt_output="$1"; shift;;
    -v | --verbose ) opt_verbose='true';;
    -h | --help    ) printf "%s\n" "$USAGE"; exit 0;;

    # process special cases
    --) while [ "$1" != "$EOL" ]; do set -- "$@" "$1"; shift; done;;   # parse remaining as positional
    --[!=]*=*) set -- "${opt%%=*}" "${opt#*=}" "$@";;                  # "--opt=arg"  ->  "--opt" "arg"
    -[A-Za-z0-9] | -*[!A-Za-z0-9]*) exit2 "invalid option" "$opt";;    # anything invalid like '-*'
    -?*) other="${opt#-?}"; set -- "${opt%"$other"}" "-${other}" "$@";;  # "-abc"  ->  "-a" "-bc"
    *) set -- "$@" "$opt";;                                            # positional, rotate to the end
  esac
done; shift

positional_arg1="${1:-default}"
positional_arg2="${2:-default}"

cleanup() {
    # Remove temporary files
    # Restart services
    echo "Cleaning up"
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT
    # Script goes here
fi
