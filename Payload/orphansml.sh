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


# --- 2026 COMPREHENSIVE SAFETY BLACKLIST ---
# Removing empty directories in these paths is BLOCKED to prevent OS crashes.
BLACKLIST=(
    # --- CORE SYSTEM & BOOT (CRITICAL) ---
    "/boot"      # [Bootloader/Kernel] Deleting subdirs here risks making the system unbootable.
    "/lib"       # [Shared Libraries] Essential shared libraries required for almost all programs.
    "/lib64"     # [64-bit Libraries] Essential for 64-bit system execution and boot.
    "/proc"      # [Kernel Interface] Virtual filesystem for process info; modification is dangerous.
    "/sys"       # [Hardware Interface] Virtual filesystem for hardware; managed only by kernel.
    "/dev"       # [Device Nodes] Essential for hardware access (disks, mouse, keyboard).
    "/usr"       # [System Binaries] Contains user-level applications; structure must remain intact.

    # --- RUNTIME & COMMUNICATIONS (STABILITY) ---
    "/run"       # [Volatile Runtime] Modern systemd path for active PIDs and sockets.
    "/var/run"   # [Legacy Runtime] Symlink to /run; essential for service communication.
    "/var/lock"  # [Device Locks] Prevents hardware conflicts between programs.

    # --- LOGS & APP STATE (SERVICE HEALTH) ---
    "/var/log"   # [System Logs] Services (Nginx/MySQL) crash if their log subfolders are missing.
    "/var/lib"   # [Persistent State] Critical for database, docker, and package manager states.
    "/etc"       # [Configuration] Heart of the system; many apps fail if subdirs vanish.

    # --- ADMIN & SERVICE DATA (PROTECTION) ---
    "/root"      # [Admin Home] Home directory for the root user; should be left untouched.
    "/opt"       # [Optional Apps] Third-party software (Chrome, Spotify) folder structures.
    "/srv"       # [Service Data] Specific data for web/FTP server deployments.
)

show_help() {
    echo "Usage: orphansml [target_directory] [options]"
    echo ""
    echo "Options:"
    echo "  --clean       Automatically remove identified orphans (requires confirmation)"
    echo "  -h, --help    Show this help message and exit"
    echo ""
    echo "Safety Status: 2026 Safety-Shield active (targets outside of \$HOME are restricted)."
    exit 0
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then show_help; fi

TARGET_DIR="${1:-.}"
CLEAN_MODE=false
[[ "$2" == "--clean" || "$1" == "--clean" ]] && CLEAN_MODE=true

# Helper to print rows consistently
print_row() {
    local status=$1
    local reason=$2
    local file=$3
    printf "%-12s %-30s | %s\n" "$status" "$reason" "$file"
}

# --- GLOBAL SAFETY SHIELD ---
# Resolves path to absolute to prevent bypass via ./ or ../
ABS_TARGET=$(realpath "$TARGET_DIR" 2>/dev/null)

for protected in "${BLACKLIST[@]}"; do
    # If target is exactly a protected dir OR a parent of one (like '/'), we block it.
    if [[ "$ABS_TARGET" == "$protected" ]] || [[ "$protected" == "$ABS_TARGET"* ]]; then
        echo -e "\n\033[1;41m  CRITICAL SAFETY ABORT  \033[0m"
        echo -e "Target: $ABS_TARGET"
        echo -e "Status: BLOCKED (Protected System Path)"
        echo -e "Reason: Removing empty directories in this tree risks a system crash."
        echo -e "------------------------------------------------------"
        exit 1
    fi
done

echo "Scanning for orphans in: $TARGET_DIR and /tmp"
echo "--------------------------------------------------------------------------------"
printf "%-12s %-30s | %s\n" "STATUS" "REASON" "FILE PATH"
echo "--------------------------------------------------------------------------------"

# --- 1. Dead Symlinks (Scan is safe) ---
DEAD_LINKS=$(find "$TARGET_DIR" -xtype l 2>/dev/null)
if [ -n "$DEAD_LINKS" ]; then
    while read -r link; do
        print_row "[ORPHAN]" "Dangling Symlink" "$link"
    done <<< "$DEAD_LINKS"
fi

# --- 2. Empty Directories (With Sub-Path Protection) ---
EMPTY_DIRS_RAW=$(find "$TARGET_DIR" -mindepth 1 -type d -empty 2>/dev/null)
FINAL_EMPTY_DIRS=""

if [ -n "$EMPTY_DIRS_RAW" ]; then
    while read -r dir; do
        IS_PROTECTED=false
        # Verify sub-directories against the blacklist
        for prot in "${BLACKLIST[@]}"; do
            if [[ "$dir" == "$prot"* ]]; then IS_PROTECTED=true; break; fi
        done

        if [ "$IS_PROTECTED" = true ]; then
            print_row "[SYS-SAFE]" "Protected system path" "$dir"
        else
            print_row "[ORPHAN]" "Empty Directory" "$dir"
            FINAL_EMPTY_DIRS+="$dir"$'\n'
        fi
    done <<< "$EMPTY_DIRS_RAW"
fi

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
if [ "$CLEAN_MODE" = true ] && [[ -n "$DEAD_LINKS" || -n "$FINAL_EMPTY_DIRS" || -n "$TO_DELETE" ]]; then
    echo -e "\n\033[1;43m  FINAL CONFIRMATION REQUIRED  \033[0m"
    read -p "Remove identified [ORPHAN] items? (y/N): " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        [ -n "$DEAD_LINKS" ] && echo "$DEAD_LINKS" | xargs -d '\n' rm -v 2>/dev/null
        [ -n "$FINAL_EMPTY_DIRS" ] && echo "$FINAL_EMPTY_DIRS" | xargs -d '\n' rmdir -v 2>/dev/null
        [ -n "$TO_DELETE" ] && echo "$TO_DELETE" | xargs -d '\n' rm -rf -v 2>/dev/null
        echo "Cleanup complete."
    else
        echo "Cleanup cancelled."
    fi
fi

