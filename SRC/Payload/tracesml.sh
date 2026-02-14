#!/bin/bash
##################################################################
# @Command:      tracesml
# @Suite:        sml-magic-tools
# @Description:  Execution tracer with high-precision timestamps
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0 (2026)
##################################################################

show_help() {
    echo "Usage: tracesml <script.sh> [args]"
    echo "Alternative: echo <script_name> | tracesml"
    echo ""
    echo "Description:"
    echo "    Runs a script in trace mode (set -x) with high-precision"
    echo "    timestamps and line numbers for performance auditing."
    echo ""
    echo "Options:"
    echo "    -h, --help    Show this help message and exit"
    exit 0
}

# 1. Handle help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
fi

# 2. PIPE LOGIC: Get script name from argument or pipe
if [ -n "${1:-}" ]; then
    TARGET_SCRIPT="$1"
    shift # Shift to handle remaining arguments for the target script
elif [ ! -t 0 ]; then
    TARGET_SCRIPT=$(cat)
else
    show_help
fi

# 3. Validation
if [[ ! -f "$TARGET_SCRIPT" ]]; then
    echo -e "\033[1;31m[ERROR]\033[0m Script '$TARGET_SCRIPT' not found."
    exit 1
fi

echo "Tracing $TARGET_SCRIPT..."
echo "------------------------------------------------------"

# 4. Execution Logic
# [Image of a sequence diagram for shell script execution tracing]
# PS4 is the internal Bash variable that defines the prefix for trace lines.
# We use ANSI colors and $(date) for nanosecond precision.
export PS4='+ \033[1;33m[$(date "+%H:%M:%S.%N")]\033[0m Line $LINENO: '

# Run the target script with xtrace enabled (-x)
bash -x "$TARGET_SCRIPT" "$@"
