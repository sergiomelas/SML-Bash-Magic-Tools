#!/bin/bash
##################################################################
# @Command:      logssml
# @Suite:        sml-magic-tools
# @Description:  Finds and follows the newest log file by keyword
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0 (2026)
##################################################################

show_help() {
    echo "Usage: logssml <keyword>"
    echo "Alternative: echo <keyword> | logssml"
    echo ""
    echo "Description:"
    echo "    Searches /var/log/ for the most recently modified file"
    echo "    containing the keyword and starts a live 'tail -f' audit."
    echo ""
    echo "Options:"
    echo "    -h, --help    Show this help message and exit"
    exit 0
}

# 1. PIPE LOGIC: Handle help and input detection
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

if [ -n "${1:-}" ]; then
    KEYWORD="$1"
elif [ ! -t 0 ]; then
    KEYWORD=$(cat)
else
    show_help
fi

# 2. Privilege Check
sudo -v

echo -e "\033[1;34m[SCANNING]\033[0m Searching /var/log for newest match: '$KEYWORD'..."

# 3. Find the newest file in /var/log recursively
# %T@ gets modification time as a timestamp for precise numerical sorting
NEWEST_LOG=$(sudo find /var/log -type f -iname "*$KEYWORD*" -printf "%T@ %p\n" 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2-)

# 4. Check results
if [ -z "$NEWEST_LOG" ]; then
    echo -e "\033[1;31m[ERROR]\033[0m No log files found matching '$KEYWORD'."
    exit 1
fi

echo -e "\033[1;32m[FOUND]\033[0m Newest log: $NEWEST_LOG"
echo "Tailing file... (Press Ctrl+C to stop)"
echo "------------------------------------------------------"

# 5. Execution
sudo tail -f "$NEWEST_LOG"
