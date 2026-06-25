##################################################################
#                        sml magic tools                         #
#        Developed for bash by sergio melas 2026                 #
#                                                                #
#                Email: sergiomelas@gmail.com                    #
#                Released under GPL V2.0                         #
#                                                                #
##################################################################

SML Magic Tools is a professional suite of 13 core utilities designed
to simplify Bash script development, real-time debugging, and system
forensics. Built for engineers who need hands-on visibility without
heavyweight dependencies.

NEW IN VERSION 1.0.2:
- Added crashsml utility for interactive kernel panic simulations.
- Native XDG Desktop Launcher integration (System_Crash.desktop).
- System-wide scalable vector icon asset deployment (bombermaaan.svg).
- Safe deterministic base directory resolution via BASH_SOURCE arrays.
- Full alignment of install/remove scripts to orchestrate all 13 core tools.

CURRENT CORE UTILITIES:

- codecksml   : Hybrid Validator. Combines 'bash -n' with ShellCheck
                to ensure syntax perfection and best-practice
                compliance before execution.

- crashsml    : Simulation SML. Zenity GUI to stage and execute controlled
                kernel panics via Magic SysRq. Includes a progress bar
                covering the execution time required to perform the crash
                safely without desktop freezes. Launcher configured as
                "SML System Crash Simulation".

- dbgsml      : Interactive Debugger. Provides step-through
                execution capabilities for Bash scripts via native traps.

- journalsml  : Live Journal Audit. Peeks into systemd journal
                events in real-time with keyword filtering.

- killsml      : Intelligent Process Terminator. Safely kills
                matching processes with confirmation prompts and safety blacklists.

- logssml      : Smart Log Finder. Automatically identifies the most
                recent log file in /var/log/ and starts a live colorized tail.

- orphansml   : System Janitor. Manages orphaned symlinks, empty
                directories, and temp files. (Use with caution).

- peeksml      : Virtual Terminal Spy. Intercepts 'write' syscalls
                via strace to peek at the output of a running
                process as if it were on your screen.

- pidsml      : Deep-Dive PID Finder. Locates Process IDs by
                filename, cross-referencing /proc for accuracy (kernel 15-char limit).

- searchjsml  : Journal Forensics. Searches historical systemd
                logs with specific relative time-range support.

- searchlsml  : Global Log Searcher. Greps through both plain-text
                and compressed (.gz) logs in /var/log/ recursively.

- throttlesml : Expert System & Inference Engine for Hardware.
                Uses Forward Chaining to diagnose system health.

- tracesml    : High-Precision Tracer. Executes scripts with
                nanosecond timestamps and line-number tracking.


INSTALLATION:
Debian/Ubuntu: sudo apt install ./sml-magic-tools_1.0.1_all.deb
Standalone:    Run with root privileges: sudo ./install.sh

##################################################################
Change log:

 -V0.1   12-02-2024: Initial developer version.
 -V1.0   26-01-2026: First public version. Integrated Debian
                     packaging, space-safe paths, and header
                     injection system.
 -V1.0.1 18-06-2026: Standardized packaging pipeline and
                     maintainer metadata updates.
 -V1.0.2 25-06-2026: Added crashsml with a timed execution progress bar.
                     Integrated desktop launcher with SVG icon, switched
                     to dynamic BASH_SOURCE path resolution, and updated
                     lifecycle scripts for all 13 tools.
##################################################################
