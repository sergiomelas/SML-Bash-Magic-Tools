#!/bin/bash
##################################################################
# @Command:      journalsml
# @Suite:        sml-magic-tools
# @Description:  Live systemd journal audit with pipe support
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0 (2026)
##################################################################

show_help() {
    echo "Usage: journalsml [keyword]"
    echo "Alternative: pidsml <name> | journalsml"
    echo ""
    echo "Description:"
    echo "    Peeks into the live systemd journal. If a keyword is provided,"
    echo "    it filters logs in real-time for that specific string."
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
    KEYWORD=$(cat)
else
    KEYWORD=""
fi

# 3. Dependency Check
if ! command -v journalctl &> /dev/null; then
    echo -e "\033[1;31m[ERROR]\033[0m 'journalctl' not found. Systemd required."
    exit 1
fi

echo "Attaching to System Journal... (Press Ctrl+C to stop)"
[ -n "$KEYWORD" ] && echo "Filtering for: '$KEYWORD'"
echo "------------------------------------------------------"

# 4. Execution
# Note: sudo is handled here to ensure access to system logs
if [ -z "$KEYWORD" ]; then
    sudo journalctl -f
else
    # --line-buffered ensures the pipe doesn't lag
    sudo journalctl -f | grep --line-buffered -i "$KEYWORD"
fi
