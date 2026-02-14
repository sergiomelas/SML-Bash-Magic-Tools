#!/bin/bash
##################################################################
# @Command:      dbgsml
# @Suite:        sml-magic-tools
# @Description:  Interactive step-through debugger for Bash scripts
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0 (2026)
##################################################################

show_help() {
    echo "Usage: dbgsml <script.sh> [arguments...]"
    echo ""
    echo "ARGUMENTS:"
    echo "  Everything following the script filename is passed directly"
    echo "  to that script. For example:"
    echo "    dbgsml install.sh --force --dir /tmp"
    echo ""
    echo "DEBUGGER COMMANDS:"
    echo "  [Enter]       - Step: Execute current line and show next"
    echo "  v <var>       - View: Show variable value (e.g., 'v PATH')"
    echo "  i <command>   - Inspect: Run any bash command (e.g., 'i ls -l')"
    echo "  q             - Quit: Stop the debugger and exit"
    echo ""
    exit 0
}

# 1. Handle help and empty input
if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    show_help
fi

debugger_step() {
    trap - DEBUG

    [[ "$BASH_COMMAND" == "debugger_step"* ]] && { trap 'debugger_step' DEBUG; return; }

    # Context detection for sourced scripts
    local current_file=$(basename "${BASH_SOURCE[1]:-$1}")
    local current_line=${BASH_LINENO[0]}

    echo -e "\033[1;33m[DEBUG PID:$$]\033[0m $current_file:$current_line \033[32m$BASH_COMMAND\033[0m"

    while true; do
        read -p "dbg> " cmd < /dev/tty
        case "$cmd" in
            "")
                trap 'debugger_step' DEBUG
                return ;;
            "q") exit 0 ;;
            v*)
                var_name=$(echo "${cmd#v }" | xargs)
                echo "Value of $var_name: ${!var_name}"
                ;;
            i*)
                inspect_cmd=$(echo "${cmd#i }" | xargs)
                eval "$inspect_cmd" < /dev/tty
                ;;
            *) echo "Enter: Step | v <var>: View | i <cmd>: Run | q: Quit" ;;
        esac
    done
}

# 2. Debugger Environment Setup
export SML_DEBUG_ACTIVE="true"
export BASH_ENV="$0"
shopt -s extdebug
set -o functrace
trap 'debugger_step' DEBUG

# 3. Execution
if [[ -f "$1" ]]; then
    TARGET_SCRIPT="$1"
    shift
    # Source allows the debugger to stay in the same shell environment
    source "$TARGET_SCRIPT" "$@"
else
    echo -e "\033[1;31m[ERROR]\033[0m File '$1' not found."
    exit 1
fi
