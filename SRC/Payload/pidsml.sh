#!/bin/bash
##################################################################
# @Command:      pidsml
# @Suite:        sml-magic-tools
# @Description:  Finds the PID of a process by its filename
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0 (2026)
##################################################################

show_help() {
    echo "Usage: pidsml <filename>"
    echo ""
    echo "Description:"
    echo "    Returns the Process ID (PID) of any running process matching"
    echo "    the provided string in the filename."
    echo ""
    echo "Options:"
    echo "    -h, --help    Show this help message and exit"
    echo ""
    echo "Note: Designed to be piped into other SML tools:"
    echo "    pidsml cron | peeksml"
    exit 0
}

# 1. Handle help and empty input
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] || [ -z "$1" ]; then
    show_help
fi

SEARCH_NAME="$1"
FOUND=0

# 2. Get candidate PIDs using pgrep (full command line match)
CANDIDATES=$(pgrep -f "$SEARCH_NAME")

for pid in $CANDIDATES; do
    # Skip our own PID and our parent's PID to avoid self-detection
    if [[ "$pid" == "$$" || "$pid" == "$PPID" ]]; then
        continue
    fi

    # 3. Deep-dive check via kernel interface (/proc)
    if [ -f "/proc/$pid/comm" ]; then
        REAL_COMM=$(cat "/proc/$pid/comm")
        # Linux kernel limits comm name to 15 characters
        TRUNCATED_SEARCH="${SEARCH_NAME:0:15}"

        # Match if the kernel name starts with our search string
        if [[ "$REAL_COMM" == "$TRUNCATED_SEARCH"* ]]; then
            echo "$pid"
            FOUND=1
        fi
    fi
done

# 4. Exit status for script integration
if [ "$FOUND" -eq 0 ]; then
    exit 1
fi
