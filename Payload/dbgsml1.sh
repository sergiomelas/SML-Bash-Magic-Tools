#!/bin/bash
# dbgsml - SML magic tools 2021-26
# An interactive step-through debugger for Bash scripts.

##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2026              #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################


show_help() {
    echo "Usage: dbgsml <script.sh> [arguments...]"
    echo ""
    echo "ARGUMENTS:"
    echo "  Everything following the script filename is passed directly"
    echo "  to that script. For example:"
    echo "    dbgsml install.sh --force --dir /tmp"
    echo "    (The debugger runs install.sh and passes it --force and --dir)"
    echo ""
    echo "DEBUGGER COMMANDS:"
    echo "  [Enter]       - Step: Execute the current line and show the next"
    echo "  v <var>       - View: Show variable value (e.g., 'v PATH')"
    echo "  i <command>   - Inspect: Run any bash command (e.g., 'i ls -l')"
    echo "  q             - Quit: Stop the debugger and exit the script"
    echo ""
    exit 0
}

# 1. Handle help and empty input
if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    show_help
fi

# 2. Capture the script and shift arguments
TARGET_SCRIPT="$1"
shift  # This moves $2 to $1, $3 to $2, etc. $@ now holds ONLY the args.

# 3. The debugger engine
debugger_step() {
    # Prevent the debugger from debugging its own internal read/eval loops
    [[ "$BASH_COMMAND" == "debugger_step"* ]] && return
    [[ "$BASH_COMMAND" == "read"* ]] && return
    [[ "$BASH_COMMAND" == "eval"* ]] && return

    echo -e "\033[1;33m[DEBUG]\033[0m Line $LINENO: \033[32m$BASH_COMMAND\033[0m"

    while true; do
        # Read from the TTY (File Descriptor 3)
        read -p "dbg> " -u 3 cmd
        case "$cmd" in
            "") return ;; # Step forward
            "q")
                echo "Exiting debugger..."
                exit 0 ;;
            v*)
                var_name=$(echo "${cmd#v }" | xargs)
                echo "Value of $var_name: ${!var_name}"
                ;;
            i*)
                inspect_cmd=$(echo "${cmd#i }" | xargs)
                echo -e "\033[1;34m[INSPECT]\033[0m Executing: $inspect_cmd"
                eval "$inspect_cmd"
                ;;
            *) echo "Commands: [Enter]=Step | v <var>=View | i <cmd>=Run | q=Quit" ;;
        esac
    done
}

# 4. Open the terminal for interactive input
exec 3< /dev/tty

# 5. Enable advanced Bash debugging
shopt -s extdebug
trap 'debugger_step' DEBUG

# 6. Execute the script with the captured arguments ($@)
if [[ -f "$TARGET_SCRIPT" ]]; then
    # Use 'source' to ensure the DEBUG trap stays active inside the target script
    source "$TARGET_SCRIPT" "$@"
else
    echo "Error: Script '$TARGET_SCRIPT' not found."
    exit 1
fi

# 7. Cleanup after script finishes
trap - DEBUG
exec 3<&-
