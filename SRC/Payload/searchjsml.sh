#!/bin/bash
##################################################################
# @Command:      searchjsml
# @Suite:        sml-magic-tools
# @Description:  Historical journal search with pipe and time support
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0 (2026)
##################################################################

show_help() {
    echo "Usage: searchjsml <keyword> [time_range]"
    echo "Alternative: pidsml <name> | searchjsml"
    echo ""
    echo "Description:"
    echo "    Searches past system logs for a keyword. Optionally limit"
    echo "    the search to a specific time range."
    echo ""
    echo "Examples:"
    echo "    searchjsml error                 (Search all history for 'error')"
    echo "    searchjsml ssh '1h ago'          (Search logs from the last hour)"
    echo "    searchjsml boot yesterday        (Search logs from yesterday)"
    echo "    searchjsml error '30m ago'       (Finds recent error in 30 mins)"
    echo ""
    echo "Options:"
    echo "    -h, --help    Show this help message and exit"
    exit 0
}

# 1. Handle help
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

# 2. PIPE LOGIC: Keyword from argument or pipe
if [ -n "${1:-}" ]; then
    KEYWORD="$1"
elif [ ! -t 0 ]; then
    # Read from Standard Input
    KEYWORD=$(cat)
else
    show_help
fi

SINCE="$2"

# 3. Dependency Check
if ! command -v journalctl &> /dev/null; then
    echo -e "\033[1;31m[ERROR]\033[0m 'journalctl' not found. Systemd required."
    exit 1
fi

# 4. Privilege Check
sudo -v

echo "Searching journal for: '$KEYWORD'..."
[ -n "$SINCE" ] && echo "Time range: since $SINCE"
echo "------------------------------------------------------"

# 5. Execution
# -g/--grep searches the message field for a pattern
# --no-pager displays all results directly to the terminal


if [ -z "$SINCE" ]; then
    sudo journalctl -g "$KEYWORD" --no-pager
else
    sudo journalctl -g "$KEYWORD" --since "$SINCE" --no-pager
fi
