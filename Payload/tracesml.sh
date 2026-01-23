#!/bin/bash
# tracesml - SML magic tools 2026
# Traces a script's execution with timestamps and line numbers.


##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2021-26           #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################

show_help() {
    echo "Usage: tracesml <script.sh> [args]"
    echo "Description: Runs a script in trace mode with high-precision timestamps."
    exit 0
}

[[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]] && show_help

TARGET_SCRIPT="$1"
shift # Pass remaining arguments to the target script

echo "Tracing $TARGET_SCRIPT..."
echo "------------------------------------------------------"
# PS4 is the prefix for 'set -x' trace lines.
# We add timestamps and line numbers for better debugging.
export PS4='+ \033[1;33m[$(date "+%H:%M:%S.%N")]\033[0m Line $LINENO: '
bash -x "$TARGET_SCRIPT" "$@"
