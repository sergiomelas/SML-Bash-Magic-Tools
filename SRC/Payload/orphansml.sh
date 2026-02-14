#!/bin/bash
##################################################################
# @Command:      orphansml
# @Suite:        sml-magic-tools
# @Description:  Finds and manages orphaned symlinks and empty dirs
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0 (2026)
##################################################################

# --- 2026 COMPREHENSIVE SAFETY BLACKLIST ---
# Removing empty directories in these paths is BLOCKED to prevent OS instability.
BLACKLIST=(
    "/boot" "/lib" "/lib64" "/proc" "/sys" "/dev" "/usr" "/etc"
    "/run" "/var/run" "/var/lock" "/var/log" "/var/lib" "/root"
    "/opt" "/srv" "$HOME/.config" "$HOME/.local" "$HOME/.cache"
    "$HOME/.mozilla" "$HOME/.pki" "$HOME/.ssh" "$HOME/.gnupg"
    "$HOME/.var/app" "$HOME/snap" "/var/lib/flatpak" "/var/lib/snapd"
    "$HOME/.steam" "$HOME/.local/share/Steam" "$HOME/.nv"
    "$HOME/.cache/nvidia" "/lost+found" "$HOME/.wine"
)

show_help() {
    echo "Usage: orphansml [target_directory] [options]"
    echo ""
    echo "Options:"
    echo "  --clean       Automatically remove identified orphans (requires confirmation)"
    echo "  -h, --help    Show this help message and exit"
    echo ""
    echo "Safety Status: 2026 Safety-Shield active (core system paths are skipped)."
    exit 0
}

# 1. Handle help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then show_help; fi

TARGET_DIR="${1:-.}"
CLEAN_MODE=false
[[ "$1" == "--clean" || "$2" == "--clean" ]] && CLEAN_MODE=true

# Resolve absolute path to handle spaces and prevent bypass
ABS_TARGET=$(realpath "$TARGET_DIR" 2>/dev/null)

# --- GLOBAL SAFETY SHIELD ---
if [[ "$ABS_TARGET" == "/" ]] || [[ "$ABS_TARGET" == "/usr" ]]; then
    echo -e "\n\033[1;41m  CRITICAL SAFETY ABORT  \033[0m"
    echo -e "Reason: Targeting the OS root is forbidden."
    exit 1
fi

print_row() {
    local status=$1
    local reason=$2
    local file=$3
    printf "%-12s %-30s | %s\n" "$status" "$reason" "$file"
}

echo "Scanning for orphans in: $ABS_TARGET and /tmp"
echo "--------------------------------------------------------------------------------"
printf "%-12s %-30s | %s\n" "STATUS" "REASON" "FILE PATH"
echo "--------------------------------------------------------------------------------"

# --- 1. Dead Symlinks ---
DEAD_LINKS=""
while IFS= read -r -d '' link; do
    IS_PROT=false
    for prot in "${BLACKLIST[@]}"; do [[ "$link" == "$prot"* ]] && IS_PROT=true && break; done

    if [ "$IS_PROT" = true ]; then
        print_row "[SYS-SAFE]" "Critical system link" "$link"
    else
        print_row "[ORPHAN]" "Dangling Symlink" "$link"
        DEAD_LINKS+="$link"$'\n'
    fi
done < <(find "$TARGET_DIR" -xtype l -print0 2>/dev/null)

# --- 2. Empty Directories ---
FINAL_EMPTY_DIRS=""
while IFS= read -r -d '' dir; do
    IS_PROTECTED=false
    for prot in "${BLACKLIST[@]}"; do
        if [[ "$dir" == "$prot"* ]]; then IS_PROTECTED=true; break; fi
    done

    if [ "$IS_PROTECTED" = true ]; then
        print_row "[SYS-SAFE]" "System critical structure" "$dir"
    else
        print_row "[ORPHAN]" "Empty Directory" "$dir"
        FINAL_EMPTY_DIRS+="$dir"$'\n'
    fi
done < <(find "$TARGET_DIR" -mindepth 1 -type d -empty -print0 2>/dev/null)

# --- 3. Temporary Files Analysis ---
TO_DELETE=""
for f in /tmp/*; do
    [ ! -e "$f" ] && continue
    [[ "$f" == *"systemd-private"* ]] && { print_row "[SYS-PROT]" "Sandbox" "$f"; continue; }
    [[ ! -w "$f" ]] && { print_row "[NOACCESS]" "Other user" "$f"; continue; }

    PID_CANDIDATE=$(echo "$f" | grep -oE '[0-9]{3,7}' | head -n1)
    if [[ -n "$PID_CANDIDATE" ]]; then
        if ! ps -p "$PID_CANDIDATE" >/dev/null 2>&1; then
            print_row "[ORPHAN]" "Dead PID $PID_CANDIDATE" "$f"
            TO_DELETE+="$f"$'\n'
        else
            print_row "[ACTIVE]" "Running PID $PID_CANDIDATE" "$f"
        fi
    fi
done

# --- Cleanup Logic ---
FOUND_ORPHANS=false
[[ -n "$DEAD_LINKS" || -n "$FINAL_EMPTY_DIRS" || -n "$TO_DELETE" ]] && FOUND_ORPHANS=true

if [ "$FOUND_ORPHANS" = true ]; then
    if [ "$CLEAN_MODE" = true ]; then
        echo -e "\n\033[1;43m  FINAL CONFIRMATION REQUIRED  \033[0m"
        read -p "Remove identified [ORPHAN] items? (y/N): " CONFIRM
        if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
            echo -e "\n\033[1;32mPROGRESS     ACTION                         | FILE PATH\033[0m"
            echo "--------------------------------------------------------------------------------"
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                rm "$line" 2>/dev/null && print_row "[CLEANED]" "Dangling Symlink" "$line"
            done <<< "$DEAD_LINKS"
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                rmdir "$line" 2>/dev/null && print_row "[CLEANED]" "Empty Directory" "$line"
            done <<< "$FINAL_EMPTY_DIRS"
            while IFS= read -r line; do
                [[ -z "$line" ]] && continue
                rm -rf "$line" 2>/dev/null && print_row "[CLEANED]" "Temporary File" "$line"
            done <<< "$TO_DELETE"
            echo -e "\nCleanup complete."
        else
            echo "Cleanup cancelled."
        fi
    else
        echo -e "\n\033[1;33mSCAN COMPLETE\033[0m: Orphans found. Run with --clean to remove them."
    fi
else
    echo -e "\n\033[1;32m✓ SYSTEM CLEAN\033[0m: No orphans found."
fi
