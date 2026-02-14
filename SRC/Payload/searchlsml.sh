#!/bin/bash
##################################################################
# @Command:      searchlsml
# @Suite:        sml-magic-tools
# @Description:  Global log searcher (plain-text and .gz support)
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0 (2026)
##################################################################

show_help() {
    echo "Usage: searchlsml <keyword> [directory]"
    echo "Alternative: pidsml <name> | searchlsml"
    echo ""
    echo "Description:"
    echo "    Searches all logs in /var/log (or a specific directory) for"
    echo "    a keyword. Automatically handles .gz compressed logs."
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

SEARCH_DIR="${2:-/var/log}"

# 3. Verify search directory
if [ ! -d "$SEARCH_DIR" ]; then
    echo -e "\033[1;31m[ERROR]\033[0m Directory $SEARCH_DIR does not exist."
    exit 1
fi

# 4. Privilege Check
sudo -v

echo "Searching logs for: '$KEYWORD' in $SEARCH_DIR..."
echo "------------------------------------------------------"

# 5. Search Logic
# [Image of the grep command and regex matching process]
# zgrep handles both normal text and gzipped files automatically.
# -r: recursive search
# -a: treat binary files as text
# -I: ignore actual binary files (prevents noise)
sudo zgrep -raI "$KEYWORD" "$SEARCH_DIR" 2>/dev/null | \
awk -F: '{printf "\033[1;32m%s\033[0m: %s\n", $1, $2}'

echo "------------------------------------------------------"
echo "Search complete."
