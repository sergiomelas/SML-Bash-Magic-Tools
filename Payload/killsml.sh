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

# --- THE CRITICAL PROCESS BLACKLIST ---
# Organized by category to spread across various distributions (Debian, RHEL, Arch, etc.)
# and protect both server-grade and modern 2026 desktop-grade systems.
BLACKLIST=(
    # --- [CLASS: CORE INIT & KERNEL] ---
    "systemd"         # PID 1: Root of all processes. Killing this = Instant system crash.
    "init"            # Legacy/Container init.
    "kthreadd"        # PID 2: Parent of all kernel threads. Essential for CPU/RAM task management.
    "kworker"         # Kernel worker threads. Handling them incorrectly causes a hard freeze.
    "ksoftirqd"       # Kernel software interrupt handler. Required for network/disk I/O.
    "migration"       # CPU scheduler thread. Moves tasks between cores; killing it hangs the CPU.
    "cpuhp"           # CPU Hotplug handler. Prevents hardware lockups during power scaling.

    # --- [CLASS: SYSTEM SERVICES & BUSES] ---
    "dbus-daemon"     # The "nervous system" of Linux. If this dies, almost all UI/Apps stop talking.
    "udevd"           # Device manager. Required for your mouse, keyboard, and disks to work.
    "systemd-journal" # Modern logging (Journald). If killed, you lose all error/audit logs.
    "polkitd"         # Authorization manager. Required for any 'sudo' or root actions.
    "accounts-daemon" # Manages user accounts and login sessions.

    # --- [CLASS: DISPLAY SERVERS & GRAPHICS] ---
    "Xorg"            # Legacy X11 display engine.
    "Xwayland"        # X11 compatibility for modern Wayland sessions.
    "wayland"         # Modern 2026 standard display protocol.
    "gnome-shell"     # GNOME Desktop engine.
    "plasmashell"     # KDE Plasma Desktop engine.
    "sway"            # Popular tiling compositor.
    "hyprland"        # High-performance Wayland compositor.
    "mutter"          # GNOME Window manager.
    "kwin"            # KDE Window manager.
    "xfwm4"           # XFCE Window manager.

    # --- [CLASS: NETWORKING & REMOTE ACCESS] ---
    "NetworkManager"  # Standard networking daemon. Killing this drops Wi-Fi/Ethernet.
    "iwd"             # Modern wireless daemon (common on Arch/Fedora).
    "sshd"            # Remote access. Prevents being locked out of a server.
    "avahi-daemon"    # Network service discovery (mDNS).
    "wpa_supplicant"  # Essential Wi-Fi authentication tool.

    # --- [CLASS: LOGIN & TERMINAL SESSIONS] ---
    "login"           # The process managing your physical or virtual terminal login.
    "bash"            # Protects your current shell from accidental suicide.
    "zsh"             # Alternative shell protection.
    "fish"            # Friendly Interactive Shell protection.
    "tmux"            # Prevents losing multiple terminal sessions.
    "screen"          # Legacy terminal multiplexer.
    "agetty"          # Standard TTY login process.

    # --- [CLASS: VIRTUALIZATION & CLOUD] ---
    "dockerd"         # Docker daemon. Protects all running containers.
    "containerd"      # Modern container runtime engine.
    "libvirtd"        # KVM/QEMU virtual machine manager.
    "qemu-system"     # Protects active Virtual Machines from being shut down.
    "cloud-init"      # Critical for server provisioning and cloud instances.
)

show_help() {
    echo "Usage: killsml <substring>"
    echo "Safety Threshold: $MAX_THRESHOLD | Protection: FULL BLACKLIST ACTIVE"
    exit 0
}

# Standard input checks
[[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]] && show_help

SEARCH_NAME="$1"

# 1. Gather matches excluding self and parent
MATCHES=$(pgrep -fa "$SEARCH_NAME" | grep -vE "$$|$PPID|killsml")

if [ -z "$MATCHES" ]; then
    echo "No processes found matching: '$SEARCH_NAME'."
    exit 0
fi

# 2. Count matches
COUNT=$(echo "$MATCHES" | wc -l)

# 3. BLACKLIST ENFORCEMENT
while read -r line; do
    # Check if any part of the command line contains a blacklisted word
    for protected in "${BLACKLIST[@]}"; do
        if [[ "$line" == *"$protected"* ]]; then
            echo -e "\n\033[1;41m [PROTECTION TRIGGERED] \033[0m"
            echo -e "\033[1mSearch Term:\033[0m   $SEARCH_NAME"
            echo -e "\033[1mBlocked Match:\033[0m $protected"
            echo -e "\033[1mProcess Line:\033[0m  $line"
            echo -e "------------------------------------------------------"
            echo -e "CRITICAL: This is a protected system component."
            echo -e "Terminating this would destabilize your operating system."
            echo -e "Operation ABORTED."
            exit 1
        fi
    done
done <<< "$MATCHES"

# 4. VOLUME SAFETY
if [ "$COUNT" -gt "$MAX_THRESHOLD" ]; then
    echo -e "\n\033[1;41m [DANGER: TOO MANY PROCESSES] \033[0m"
    echo -e "Your search matched $COUNT processes."
    echo -e "The safety limit is $MAX_THRESHOLD. Refine your search string."
    echo -e "Process list hidden for your safety."
    exit 1
else
    # 5. FINAL CONFIRMATION
    echo "Matches found: $COUNT"
    echo "------------------------------------------------------"
    echo "$MATCHES"
    echo "------------------------------------------------------"
    echo -e "\033[1;33mProceed to kill these $COUNT processes? (y/N):\033[0m "
    read -p "> " CONFIRM

    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        PIDS=$(echo "$MATCHES" | awk '{print $1}')
        # Using -15 (SIGTERM) for a graceful shutdown
        echo "$PIDS" | xargs sudo kill -15 2>/dev/null
        echo "Successfully sent SIGTERM to $COUNT processes."
    else
        echo "Operation cancelled."
    fi
fi
