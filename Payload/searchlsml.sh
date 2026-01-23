#!/bin/bash
# searchlsml - SML magic tools 2021-26
# Searches through both plain-text and compressed log files.

##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2021-26           #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################

show_help() {
    echo "Usage: searchlsml <keyword> [directory]"
    echo ""
    echo "Description:"
    echo "    Searches all logs in /var/log (or a specific directory) for"
    echo "    a keyword. Automatically handles .gz compressed logs."
    echo ""
    echo "Options:"
    echo "    -h, --help    Show this help message and exit"
    exit 0
}

# 1. Check for help
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] || [ -z "$1" ]; then
    show_help
fi

KEYWORD="$1"
SEARCH_DIR="${2:-/var/log}"

# 2. Verify search directory
if [ ! -d "$SEARCH_DIR" ]; then
    echo "Error: Directory $SEARCH_DIR does not exist."
    exit 1
fi

echo "Searching logs for: '$KEYWORD' in $SEARCH_DIR..."
echo "------------------------------------------------------"

# 3. Search Logic
# zgrep handles both normal text and gzipped files automatically.
# -r: recursive search
# -a: treat binary files as text
# -I: ignore binary files that are not compressed text
sudo zgrep -raI "$KEYWORD" "$SEARCH_DIR" 2>/dev/null | awk -F: '{printf "\033[1;32m%s\033[0m: %s\n", $1, $2}'

echo "------------------------------------------------------"
echo "Search complete."
