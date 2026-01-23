#!/bin/bash
# pidsml command to find the PID of a process by its filename
# Usage: pidsml <filename>

##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2021-26           #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################

show_help() {
    echo "Usage: pidsml <filename>"
    echo ""
    echo "Description:"
    echo "    Returns the Process ID (PID) of any running process matching"
    echo "    the provided string in the filename. "
    echo ""
    echo "Options:"
    echo "    -h, --help    Show this help message and exit"
    exit 0
}



if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] || [ -z "$1" ]; then
    show_help
fi

SEARCH_NAME="$1"
FOUND=0

# 1. Get candidate PIDs that mention the search name
CANDIDATES=$(pgrep -f "$SEARCH_NAME")

for pid in $CANDIDATES; do
    # Skip our own PID and our parent's PID
    if [[ "$pid" == "$$" || "$pid" == "$PPID" ]]; then
        continue
    fi

    # Deep-dive check: Compare kernel process name (comm) to search string
    if [ -f "/proc/$pid/comm" ]; then
        REAL_COMM=$(cat "/proc/$pid/comm")
        TRUNCATED_SEARCH="${SEARCH_NAME:0:15}"

        # Match if the kernel name starts with our truncated search string
        if [[ "$REAL_COMM" == "$TRUNCATED_SEARCH"* ]]; then
            echo "$pid"
            FOUND=1
        fi
    fi
done

if [ "$FOUND" -eq 0 ]; then
    exit 1
fi
