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

MAX_THRESHOLD=5

show_help() {
    echo "Usage: killsml <substring>"
    echo "Description: Kills processes matching the substring."
    echo "Safety: Aborts and hides list if matches > $MAX_THRESHOLD."
    exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
    show_help
fi

SEARCH_NAME="$1"

# 1. Gather matches
MATCHES=$(pgrep -fa "$SEARCH_NAME" | grep -vE "$$|$PPID|killsml")

if [ -z "$MATCHES" ]; then
    echo "No processes found matching: $SEARCH_NAME"
    exit 0
fi

# 2. Count matches
COUNT=$(echo "$MATCHES" | wc -l)

# 3. SAFETY LOGIC
if [ "$COUNT" -gt "$MAX_THRESHOLD" ]; then
    # High Volume: Hide the list to avoid confusion and prevent accidents
    echo -e "\n\033[1;41m  !!! DANGER: HIGH VOLUME MATCH !!!  \033[0m"
    echo -e "\033[1;31mFound $COUNT processes matching '$SEARCH_NAME'.\033[0m"
    echo -e "------------------------------------------------------"
    echo -e "ABORTED: This search is too generic (matched $COUNT PIDs)."
    echo -e "Please use a more specific search term to avoid system damage."
    echo -e "------------------------------------------------------"
    exit 1
else
    # 4. NORMAL CONFIRMATION (for 1 to 5 processes)
    echo "Matches found: $COUNT"
    echo "------------------------------------------------------"
    echo "$MATCHES"
    echo "------------------------------------------------------"

    echo -e "\033[1;33mWARNING:\033[0m You are about to kill $COUNT processes."
    read -p "Proceed? (y/N): " CONFIRM

    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        PIDS=$(echo "$MATCHES" | awk '{print $1}')
        echo "Killing $COUNT processes..."
        echo "$PIDS" | xargs sudo kill -15 2>/dev/null
        echo "Done."
    else
        echo "Operation cancelled."
    fi
fi
