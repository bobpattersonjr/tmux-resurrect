#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PANE_PID="$1"

exit_safely_if_empty_ppid() {
	if [ -z "$PANE_PID" ]; then
		exit 0
	fi
}

full_command() {
	# Use a timeout to prevent hangs when a pane has a deep process tree.
	# Falls back to no output (safe - resurrect treats empty as shell).
	if command -v gtimeout >/dev/null 2>&1; then
		gtimeout 5 ps -ao "ppid,args" 2>/dev/null
	elif command -v timeout >/dev/null 2>&1; then
		timeout 5 ps -ao "ppid,args" 2>/dev/null
	else
		ps -ao "ppid,args" 2>/dev/null
	fi |
		sed "s/^ *//" |
		grep "^${PANE_PID}" |
		cut -d' ' -f2-
}

main() {
	exit_safely_if_empty_ppid
	full_command
}
main
