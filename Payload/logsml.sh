#!/bin/bash
# logssml - SML magic tools 2021-26
# Automatically finds and follows the newest log file matching a keyword.


##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2021-26           #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################

show_help() {
    echo "Usage: logssml <keyword>"
    echo ""
    echo "Description:"
    echo "    Searches /var/log/ for the most recently modified file"
    echo "    containing the keyword and starts 'tail -f' on it providing a live audit of events"
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

echo "Searching for the newest log matching: '$KEYWORD'..."

# 2. Find the newest file in /var/log recursively
# %T@ gets modification time as a timestamp for numerical sorting
# head -n1 picks the newest result
NEWEST_LOG=$(sudo find /var/log -type f -iname "*$KEYWORD*" -printf "%T@ %p\n" 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2-)

# 3. Check if we found anything
if [ -z "$NEWEST_LOG" ]; then
    echo "Error: No log files found in /var/log matching '$KEYWORD'."
    exit 1
fi

echo "Found newest log: $NEWEST_LOG"
echo "Tailing file... (Press Ctrl+C to stop)"
echo "------------------------------------------------------"

# 4. Tail the log
sudo tail -f "$NEWEST_LOG"
