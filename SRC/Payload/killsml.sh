#!/bin/bash
##################################################################
# @Command:      killsml
# @Suite:        sml-magic-tools
# @Description:  Safe process terminator with Blacklist protection
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0 (2026)
##################################################################

MAX_THRESHOLD=5

# --- THE CRITICAL PROCESS BLACKLIST ---
# Protects both server-grade and modern 2026 desktop-grade systems.
BLACKLIST=(
    "systemd" "init" "kthreadd" "kworker" "ksoftirqd" "migration" "cpuhp"
    "dbus-daemon" "udevd" "systemd-journal" "polkitd" "accounts-daemon"
    "Xorg" "Xwayland" "wayland" "gnome-shell" "plasmashell" "sway" "hyprland"
    "mutter" "kwin" "xfwm4" "NetworkManager" "iwd" "sshd" "avahi-daemon"
    "wpa_supplicant" "login" "bash" "zsh" "fish" "tmux" "screen" "agetty"
    "dockerd" "containerd" "libvirtd" "qemu-system" "cloud-init"
)

show_help() {
    echo "Usage: killsml <substring>"
    echo "Alternative: pidsml <name> | killsml"
    echo ""
    echo "Description: Lists processes matching the substring and asks to kill them."
    echo "Safety Threshold: $MAX_THRESHOLD | Protection: FULL BLACKLIST ACTIVE"
    exit 0
}

# 1. PIPE LOGIC: Handle help and input detection
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

if [ -n "${1:-}" ]; then
    SEARCH_NAME="$1"
elif [ ! -t 0 ]; then
    SEARCH_NAME=$(cat)
else
    show_help
fi

# 2. Gather matches excluding self and parent
MATCHES=$(pgrep -fa "$SEARCH_NAME" | grep -vE "$$|$PPID|killsml")

if [ -z "$MATCHES" ]; then
    echo "No processes found matching: '$SEARCH_NAME'."
    exit 0
fi

# 3. Count matches
COUNT=$(echo "$MATCHES" | wc -l)

# 4. Privilege Check
sudo -v

# 5. BLACKLIST ENFORCEMENT
while read -r line; do
    for protected in "${BLACKLIST[@]}"; do
        if [[ "$line" == *"$protected"* ]]; then
            echo -e "\n\033[1;41m [PROTECTION TRIGGERED] \033[0m"
            echo -e "Search Term:    $SEARCH_NAME"
            echo -e "Blocked Match:  $protected"
            echo -e "Process Line:   $line"
            echo -e "------------------------------------------------------"
            echo -e "CRITICAL: Protected system component detected."
            echo -e "Operation ABORTED to prevent system instability."
            exit 1
        fi
    done
done <<< "$MATCHES"

# 6. VOLUME SAFETY & FINAL CONFIRMATION
if [ "$COUNT" -gt "$MAX_THRESHOLD" ]; then
    echo -e "\n\033[1;41m [DANGER: TOO MANY PROCESSES] \033[0m"
    echo -e "Your search matched $COUNT processes (Limit: $MAX_THRESHOLD)."
    echo -e "Refine your search string for safety."
    exit 1
else
    echo "Matches found: $COUNT"
    echo "------------------------------------------------------"
    echo "$MATCHES"
    echo "------------------------------------------------------"
    echo -ne "\033[1;33mProceed to kill these $COUNT processes? (y/N):\033[0m "
    read -r CONFIRM

    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        PIDS=$(echo "$MATCHES" | awk '{print $1}')
        # Using -15 (SIGTERM) for a graceful shutdown
        echo "$PIDS" | xargs sudo kill -15 2>/dev/null
        echo "Successfully sent SIGTERM to $COUNT processes."
    else
        echo "Operation cancelled."
    fi
fi
