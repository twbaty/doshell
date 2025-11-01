#!/usr/bin/env bash
# ==============================================================================
# DOSHELL — version / info utility
# Author: Tom Baty
# Version helper for DOSHELL installation
# ==============================================================================

VERSION_FILE="$HOME/Documents/code/doshell/VERSION"
LOG_FILE="$HOME/.doshell.log"
DEPS_FILE="$HOME/.doshell.deps"

if [ -f "$VERSION_FILE" ]; then
  VERSION="$(cat "$VERSION_FILE")"
else
  VERSION="unknown"
fi

echo "DOSHELL — Windows-style command aliases for Linux"
echo "Version: $VERSION"
echo

if [ -f "$LOG_FILE" ]; then
  echo "Log file: $LOG_FILE"
  echo "  Last 3 log entries:"
  tail -n 3 "$LOG_FILE"
  echo
else
  echo "No DOSHELL log file found."
  echo
fi

if [ -f "$DEPS_FILE" ]; then
  echo "Dependencies installed by DOSHELL:"
  cat "$DEPS_FILE"
else
  echo "No recorded dependency installations."
fi
