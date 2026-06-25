#!/bin/bash
##################################################################
# @Command:      crashsml
# @Suite:        sml-magic-tools
# @Description:  Interactive Kernel Crash Simulation (Zenity UI)
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.8 (2026)
##################################################################

# 1. Request the sudo password using Zenity
PASS=$(zenity --password --title="Prepare kernel for safe crash")

if [ -z "$PASS" ]; then
    zenity --error --text="Simulation aborted: Password required."
    exit 1
fi

# 2. Initial Confirmation & Environment Preparation
if zenity --question --title="PREPARE CRASH CONFIGURATION" --text="Do you want to initialize the kernel execution pipeline?\n(This will NOT crash yet, it only prepares the trigger)" --width=400
then
    # Group the slow commands inside a subshell and pipe progress percentages to Zenity.
    (
        echo "5"
        echo "# Flashing cached data blocks to storage (safety sync)..."
        sync
        sleep 0.5

        echo "20"
        echo "# Elevating execution privileges with Sudo..."
        sleep 0.5

        echo "40"
        echo "# Disabling automatic reboots (Force permanent freeze)..."
        echo "$PASS" | sudo -S sysctl -w kernel.panic=0
        sleep 0.5

        echo "60"
        echo "# Unlocking Magic SysRq kernel keys interface..."
        echo "$PASS" | sudo -S sysctl -w kernel.sysrq=1
        sleep 1

        echo "80"
        echo "# Overriding fallback system runtime protection limits..."
        echo "$PASS" | sudo -S bash -c "echo 1 > /proc/sys/kernel/sysrq"
        sleep 1.5

        echo "100"
        echo "# Execution pipeline fully primed!"
        sleep 0.5
    ) 2>/dev/null | zenity --progress --title="Prepare kernel for safe crash" --text="Initializing..." --percentage=0 --auto-close --no-cancel --width=450

    # 3. THE TRIGGER BUTTON: Everything is ready.
    if zenity --question --title="TRIGGER READY" --text="PREPARATION COMPLETE.\n\nClick '💥 BOOM!' to instantly crash the system now, or 'Cancel' to disarm." --width=400 --ok-label="💥 BOOM!" --cancel-label="Cancel"
    then
        # The progress bar runs actively WHILE the system execution triggers.
        (
            echo "10"
            echo "# Initiating violent kernel halt sequence..."
            sleep 2

            echo "30"
            echo "# Switching active display server to Console TTY1..."
            echo "$PASS" | sudo -S chvt 1 2>/dev/null
            sleep 2

            echo "60"
            echo "# Sending subsystem break signals to terminal driver..."
            echo "$PASS" | sudo -S bash -c "echo sb > /proc/sysrq-trigger" 2>/dev/null
            sleep 3

            echo "90"
            echo "# Dropping CPU scheduler allocation tables..."

            # The final fatal stroke hit right at the end of the visible bar
            echo "$PASS" | sudo -S bash -c "echo c > /proc/sysrq-trigger" 2>/dev/null
        ) | zenity --progress --title="Crashing system" --text="Executing hardware panic..." --percentage=0 --auto-close --no-cancel --width=450

        exit 0
    else
        zenity --info --text="Simulation disarmed safely."
        exit 0
    fi
else
    zenity --info --text="Simulation cancelled safely."
    exit 0
fi
