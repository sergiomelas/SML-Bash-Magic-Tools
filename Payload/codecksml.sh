#!/bin/bash
# codecksml - SML magic tools 2021-26
# Hybrid Checker Combines Bash -n and ShellCheck for total validation.

##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2021-26           #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################


show_help() {
    echo "Usage: codecksml <script.sh>"
    echo ""
    echo "Description:"
    echo "    1. Performs a fast Bash syntax check (bash -n)."
    echo "    2. Runs ShellCheck for deep analysis and best practices."
    echo ""
    echo "Options:"
    echo "    -h, --help    Show this help message and exit"
    exit 0
}

# 1. Initialization and Input Validation
if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    show_help
fi

TARGET_SCRIPT="$1"

if [[ ! -f "$TARGET_SCRIPT" ]]; then
    echo -e "\033[1;31m[ERROR]\033[0m File '$TARGET_SCRIPT' not found."
    exit 1
fi

# 2. Level 1: Bash Internal Syntax Check
echo -e "\033[1;34m[STEP 1]\033[0m Running internal Bash syntax check..."
ERRORS=$(bash -n "$TARGET_SCRIPT" 2>&1)
if [[ $? -ne 0 ]]; then
    echo -e "\033[1;31m[FAILED]\033[0m Critical syntax errors found:"
    echo "$ERRORS"
    exit 1
fi
echo -e "\033[1;32m[PASS]\033[0m Basic syntax is valid."

# 3. Level 2: ShellCheck Deep Analysis
echo -e "\n\033[1;34m[STEP 2]\033[0m Running ShellCheck deep analysis..."

if ! command -v shellcheck &> /dev/null; then
    echo -e "\033[1;33m[NOTICE]\033[0m ShellCheck is not installed. Skipping deep analysis."
    echo "To enable, run: sudo apt install shellcheck"
else
    # -x allows following 'source' statements
    # -C uses colorized output for readability
    shellcheck -x -C "$TARGET_SCRIPT"
    SC_RESULT=$?

    if [[ $SC_RESULT -eq 0 ]]; then
        echo -e "\n\033[1;32m[PERFECT]\033[0m No issues or best-practice warnings detected."
    else
        echo -e "\n\033[1;33m[WARNING]\033[0m ShellCheck found potential improvements (see above)."
        exit $SC_RESULT
    fi
fi
