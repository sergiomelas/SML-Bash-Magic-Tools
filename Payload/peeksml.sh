#!/bin/bash
# peeksml command to see the output of a bash process emulating a terminal
# Usage: peeksml <pid number>

##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2021-26           #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################

# --- Help Function ---
show_help() {
    echo "Usage: peeksml <PID>"
    echo ""
    echo "Description:"
    echo "    Peeks at the real-time output of a running process by"
    echo "    intercepting 'write' system calls via strace."
    echo ""
    echo "Features:"
    echo "    - Interprets \r (carriage returns) for inline line updates."
    echo "    - Strips 'pw-dump' noise to prevent broken formatting."
    echo "    - Handles octal escape sequences for character accuracy."
    echo "    - Requires sudo privileges to attach to the target PID."
    echo ""
    echo "Options:"
    echo "    -h, --help    Show this help message and exit"
    echo ""
    echo "Note to trace a service from its name use pipeing from pidsml:"
    echo "   pidsml cron | peeksml"
    exit 0
}


# 1. Check for help
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

# 2. Get PID from argument or Pipe
PID="$1"
if [ -z "$PID" ]; then
    # If no argument, read from stdin (the pipe)
    read -t 1 PID
fi

# 3. Final check
if [ -z "$PID" ]; then
    echo "Error: No PID provided."
    show_help
    exit 1
fi

# Check if process exists
if ! ps -p "$PID" > /dev/null 2>&1; then
    echo "Error: Process ID $PID is not running."
    exit 1
fi

# 1. Login
echo  "Login as administrator"
sudo ls >/dev/null
echo  ""

echo "Attaching to process $PID... (Ctrl+C to detach)"
echo "Starting Virtual Terminal"
echo " "


# Intercept write calls and clean the output using Perl
sudo strace -p "$PID" -s 9999 -e write -e signal=none 2>&1 | \
perl -ne '
    if (/write\(1, "(.*?)", \d+\)/) {
        $s = $1;
        next if $s =~ /pw-dump/;
        $s =~ s/\\r/\r/g;
        $s =~ s/\\n/\n/g;
        $s =~ s/\\t/\t/g;
        $s =~ s/\\([0-7]{3})/chr(oct($1))/ge;
        print $s;
        STDOUT->flush();
    }
'
