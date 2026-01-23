#!/bin/bash
# orphansml - SML magic tools 2021-26
# Finds and manages orphaned symlinks, empty folders, and abandoned temp files.

##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2021-26           #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################

show_help() {
    echo "Usage: orphansml [target_directory] [options]"
    echo ""
    echo "Options:"
    echo "  --clean       Automatically remove identified orphans (requires confirmation)"
    echo "  -h, --help    Show this help message and exit"
    echo ""
    echo "Default target: /tmp and current directory"
    exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then show_help; fi

TARGET_DIR="${1:-.}"
CLEAN_MODE=false
[[ "$2" == "--clean" || "$1" == "--clean" ]] && CLEAN_MODE=true

# Helper to print rows consistently
# Format: [Status] Reason | File
print_row() {
    local status=$1
    local reason=$2
    local file=$3
    printf "%-12s %-30s | %s\n" "$status" "$reason" "$file"
}

echo "Scanning for orphans in: $TARGET_DIR and /tmp"
echo "--------------------------------------------------------------------------------"
printf "%-12s %-30s | %s\n" "STATUS" "REASON" "FILE PATH"
echo "--------------------------------------------------------------------------------"

# --- 1. Dead Symlinks ---
DEAD_LINKS=$(find "$TARGET_DIR" -xtype l 2>/dev/null)
if [ -n "$DEAD_LINKS" ]; then
    while read -r link; do
        print_row "[ORPHAN]" "Dangling Symlink" "$link"
    done <<< "$DEAD_LINKS"
fi

# --- 2. Empty Directories ---
EMPTY_DIRS=$(find "$TARGET_DIR" -type d -empty 2>/dev/null)
if [ -n "$EMPTY_DIRS" ]; then
    while read -r dir; do
        print_row "[ORPHAN]" "Empty Directory" "$dir"
    done <<< "$EMPTY_DIRS"
fi

# --- 3. Temporary Files Analysis ---
TO_DELETE=""

for f in /tmp/*; do
    # Systemd Private folders (System Protection)
    if [[ "$f" == *"systemd-private"* ]]; then
        print_row "[SYS-PROT]" "System Service Sandbox" "$f"
        continue
    fi

    # Sticky Bit protection (No Access)
    if [[ ! -w "$f" ]]; then
        print_row "[NOACCESS]" "Owned by another user" "$f"
        continue
    fi

    # PID Matching logic
    PID_CANDIDATE=$(echo "$f" | grep -oE '[0-9]{3,7}' | head -n1)
    if [[ -n "$PID_CANDIDATE" ]]; then
        if ! ps -p "$PID_CANDIDATE" >/dev/null 2>&1; then
            print_row "[ORPHAN]" "Process $PID_CANDIDATE is dead" "$f"
            TO_DELETE+="$f"$'\n'
        else
            print_row "[ACTIVE]" "Process $PID_CANDIDATE is running" "$f"
        fi
    fi
done

# --- Cleanup Logic ---
if [ "$CLEAN_MODE" = true ] && [[ -n "$DEAD_LINKS$EMPTY_DIRS$TO_DELETE" ]]; then
    echo -e "\n\033[1;41m  CLEANUP MODE ACTIVE  \033[0m"
    read -p "Remove identified [ORPHAN] items? (y/N): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        [ -n "$DEAD_LINKS" ] && echo "$DEAD_LINKS" | xargs rm -v 2>/dev/null
        [ -n "$EMPTY_DIRS" ] && echo "$EMPTY_DIRS" | xargs rmdir -v 2>/dev/null
        [ -n "$TO_DELETE" ] && echo "$TO_DELETE" | xargs rm -rf -v 2>/dev/null
        echo "Cleanup complete."
    else
        echo "Cleanup cancelled."
    fi
fi
