#!/bin/bash
##################################################################
# @Command:      peeksml
# @Suite:        sml-magic-tools
# @Description:  Virtual Terminal Spy (intercepts 'write' syscalls)
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      1.0.0 (2026)
##################################################################

show_help() {
    echo "Usage: peeksml <PID>"
    echo "Alternative: pidsml <name> | peeksml"
    echo ""
    echo "Description:"
    echo "    Peeks at the real-time output of a running process by"
    echo "    intercepting 'write' system calls via strace."
    echo ""
    echo "Features:"
    echo "    - Interprets \r (carriage returns) for inline updates."
    echo "    - Strips 'pw-dump' noise and handles octal escape sequences."
    echo "    - Requires sudo privileges to attach to the target PID."
    echo ""
    echo "Options:"
    echo "    -h, --help    Show this help message and exit"
    exit 0
}

# 1. Handle help
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

# 2. PIPE LOGIC: Get PID from argument or Pipe
if [ -n "${1:-}" ]; then
    PID="$1"
elif [ ! -t 0 ]; then
    # Read from Standard Input (the pipe)
    PID=$(cat)
else
    echo -e "\033[1;31m[ERROR]\033[0m No PID provided."
    show_help
fi

# 3. Validation
if ! [[ "$PID" =~ ^[0-9]+$ ]]; then
    echo -e "\033[1;31m[ERROR]\033[0m '$PID' is not a valid Process ID."
    exit 1
fi

if ! ps -p "$PID" > /dev/null 2>&1; then
    echo -e "\033[1;31m[ERROR]\033[0m Process ID $PID is not running."
    exit 1
fi

# 4. Privilege Check
sudo -v

echo "Attaching to process $PID... (Ctrl+C to detach)"
echo "Starting Virtual Terminal View..."
echo " "

# 5. Execution: Intercept write calls and clean output via Perl

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
