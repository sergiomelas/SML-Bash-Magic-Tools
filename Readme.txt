
##################################################################
#                       sml magic tools                          #
#       Developed for for bash by sergio melas 2026              #
#                                                                #
#                Emai: sergiomelas@gmail.com                     #
#                   Released unde GPV V2.0                       #
#                                                                #
##################################################################

A collection of bash tools developed in the years expecially for bash scripts debugging,
nothing sophisticated but quite handy.
Many I have but not ready for production, so far:

- dbgsml     : An interactive step-through debugger for Bash scripts.

- journalsml : Command to Peeks into the live systemd journal. If a keyword is provided,
               it filters logs in real-time for that specific string for new events.

- killsml    : Command to Kill all processes matching a substring with confirmation.

- logsml     : Command to Search /var/log/ for the most recently modified fil containing the
               keyword and starts a live audit of events and print them.

- peeksml    : Command to see the output of a bash process emulating a terminal.

- pidsml     : Command to find the PID of a process by its filename.

- searchjsml : Searches past system logs for a keyword. Optionally limit the search to a specific time range.

- tracesml   : Traces a script's execution with timestamps and line numbers.

Many more will came in a near future after deep testing.

To install just Run install.sh
All the command in .\Payload will be installed.

##################################################################################################################
Change log:

 -V0.1   12-02-2024: Initial version
 -V1.0   23-01-2026: First pubilic version
