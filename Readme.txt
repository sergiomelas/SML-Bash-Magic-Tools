##################################################################
#                        sml magic tools                         #
#        Developed for for bash by sergio melas 2026             #
#                                                                #
#                Email: sergiomelas@gmail.com                    #
#                    Released under GPL V2.0                     #
#                                                                #
##################################################################

SML Magic Tools is a professional suite of 11 core utilities designed
to simplify Bash script development, real-time debugging, and system
forensics. Built for engineers who need hand-on visibility without
heavyweight dependencies.

NEW IN VERSION 1.0:
- Full Debian Package integration (.deb).
- Universal Standalone support for non-Debian systems.
- Automated Header Injection with professional docstrings.
- Advanced "Virtual Terminal" process spying.

CURRENT CORE UTILITIES:

- codecksml  : Hybrid Validator. Combines 'bash -n' with ShellCheck
               to ensure syntax perfection and best-practice
               compliance before execution.

- dbgsml     : Interactive Debugger. Provides step-through
               execution capabilities for Bash scripts.

- journalsml : Live Journal Audit. Peeks into systemd journal
               events in real-time with keyword filtering.

- killsml    : Intelligent Process Terminator. Safely kills
               matching processes with confirmation prompts.

- logssml    : Smart Log Finder. Automatically identifies the most
               recent log file in /var/log/ and starts a live tail.

- orphansml  : System Janitor. Manages orphaned symlinks, empty
               directories, and temp files. (Use with caution).

- peeksml    : Virtual Terminal Spy. Intercepts 'write' syscalls
               via strace to peek at the output of a running
               process as if it were on your screen.

- pidsml     : Deep-Dive PID Finder. Locates Process IDs by
               filename, cross-referencing /proc for accuracy.

- searchjsml : Journal Forensics. Searches historical systemd
               logs with specific time-range support.

- searchlsml : Global Log Searcher. Greps through both plain-text
               and compressed (.gz) logs in /var/log/ recursively.

- tracesml   : High-Precision Tracer. Executes scripts with
               nanosecond timestamps and line-number tracking.

INSTALLATION:
Debian/Ubuntu: sudo apt install ./sml-magic-tools_1.0.0_all.deb
Standalone:    Run ./install.sh

##################################################################
Change log:

 -V0.1   12-02-2024: Initial developer version.
 -V1.0   26-01-2026: First public version. Integrated Debian
                     packaging, space-safe paths, and header
                     injection system.
##################################################################
