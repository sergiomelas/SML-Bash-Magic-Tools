#!/bin/bash
# searchjsml - SML magic tools 2021-26
# Searches historical systemd journal entries.

##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2021-26           #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################

show_help() {
    echo "Usage: searchjsml <keyword> [time_range]"
    echo ""
    echo "Description:"
    echo "    Searches past system logs for a keyword. Optionally limit"
    echo "    the search to a specific time range."
    echo ""
    echo "Examples:"
    echo "    searchjsml error                 (Search all history for 'error')"
    echo "    searchjsml ssh '1h ago'          (Search logs from the last hour)"
    echo "    searchjsml boot yesterday        (Search logs from yesterday)"
    echo "    searchjsml error '30m ago'       (Finds recent error in the last 30 minutes)"
    echo "    searchjsml NetworkManager today  (Check a specific service today)"
    echo "    searchjsml 'failed password'     (Global search no time limited)"
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
SINCE="$2"

# 2. Check for journalctl dependency
if ! command -v journalctl &> /dev/null; then
    echo "Error: 'journalctl' not found. This tool requires systemd."
    exit 1
fi

echo "Searching journal for: '$KEYWORD'..."
[ -n "$SINCE" ] && echo "Time range: since $SINCE"
echo "------------------------------------------------------"

# 3. Build the search command
# -g/--grep searches the message field for a pattern
# --no-pager displays all results at once (better for small searches)
if [ -z "$SINCE" ]; then
    sudo journalctl -g "$KEYWORD" --no-pager
else
    sudo journalctl -g "$KEYWORD" --since "$SINCE" --no-pager
fi
