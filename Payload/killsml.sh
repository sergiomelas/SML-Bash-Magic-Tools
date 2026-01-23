#!/bin/bash
# killsml - SML magic tools 2021-26
# Kills all processes matching a substring with confirmation


##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2021-26           #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################

show_help() {
    echo "Usage: killsml <substring>"
    echo "Description: Lists all processes matching the substring and asks to kill them."
    exit 0
}

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] || [ -z "$1" ]; then
    show_help
fi

SEARCH_NAME="$1"

# 1. Get list of matching processes (PID and full command line)
# -f matches full command line
# -a prints full command line
# grep -v excludes the current script and the parent shell
MATCHES=$(pgrep -fa "$SEARCH_NAME" | grep -vE "$$|$PPID|killsml")

if [ -z "$MATCHES" ]; then
    echo "No processes found matching: $SEARCH_NAME"
    exit 0
fi

# 2. Display the matches to the user
echo "Found the following processes matching '$SEARCH_NAME':"
echo "------------------------------------------------------"
echo "$MATCHES"
echo "------------------------------------------------------"

# 3. Prompt for confirmation
read -p "Do you want to kill all these processes? (y/N): " CONFIRM

if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
    # Extract only the PIDs from our list and kill them
    PIDS=$(echo "$MATCHES" | awk '{print $1}')

    echo "Killing processes..."
    # Attempt kill; use sudo if you expect to kill system or other users' processes
    echo "$PIDS" | xargs sudo kill -15 2>/dev/null

    echo "Done. (SIGTERM sent)"
else
    echo "Operation cancelled."
fi
