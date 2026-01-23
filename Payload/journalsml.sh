#!/bin/bash
# journalsml - SML magic tools 2021-26
# Follows the modern system journal (systemd) in real-time.


##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2021-26           #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################

show_help() {
    echo "Usage: journalsml [keyword]"
    echo ""
    echo "Description:"
    echo "    Peeks into the live systemd journal. If a keyword is provided,"
    echo "    it filters logs in real-time for that specific string for new events."
    echo ""
    echo "Options:"
    echo "    -h, --help    Show this help message and exit"
    exit 0
}

# 1. Check for help
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

KEYWORD="$1"

# 2. Check for journalctl dependency
if ! command -v journalctl &> /dev/null; then
    echo "Error: 'journalctl' not found. This tool requires a systemd-based OS."
    exit 1
fi

echo "Attaching to System Journal... (Press Ctrl+C to stop)"
echo "------------------------------------------------------"

# 3. Logic: Follow the journal
if [ -z "$KEYWORD" ]; then
    # No keyword: Show all logs live
    sudo journalctl -f
else
    # Keyword provided: Follow and filter using grep
    # --line-buffered ensures output appears instantly
    echo "Filtering for: '$KEYWORD'"
    sudo journalctl -f | grep --line-buffered -i "$KEYWORD"
fi
