#!/usr/bin/env bash
# ==============================================================================
# DOSHELL — Windows-style command aliases for Linux
# Author: Tom Baty
# License: MIT
# Version: 1.5 Final
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the “Software”), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ==============================================================================

VERSION_FILE="$HOME/Documents/code/doshell/VERSION"
LOG_FILE="$HOME/.doshell.log"
DEPS_FILE="$HOME/.doshell.deps"
LICENSE_NOTE="Licensed under MIT — free to use, modify, and distribute with attribution"
COPYRIGHT_NOTE="© 2025 Tom Baty"

# ------------------------------------------------------------------------------
# Display Header
# ------------------------------------------------------------------------------
if [ -f "$VERSION_FILE" ]; then
  VERSION="$(cat "$VERSION_FILE")"
else
  VERSION="v1.5 Final"
fi

echo "DOSHELL — Windows-style command aliases for Linux"
echo "Version: $VERSION"
echo "$LICENSE_NOTE"
echo "$COPYRIGHT_NOTE"
echo

# ------------------------------------------------------------------------------
# Display Log Info
# ------------------------------------------------------------------------------
if [ -f "$LOG_FILE" ]; then
  echo "Log file: $LOG_FILE"
  echo "  Last 5 log entries:"
  tail -n 5 "$LOG_FILE"
  echo
else
  echo "No DOSHELL log file found."
  echo
fi

# ------------------------------------------------------------------------------
# Display Dependency Info
# ------------------------------------------------------------------------------
if [ -f "$DEPS_FILE" ]; then
  echo "Dependencies installed by DOSHELL:"
  cat "$DEPS_FILE"
else
  echo "No recorded dependency installations."
fi

echo
echo "Repository: https://github.com/twbaty/doshell"
echo "For license details, see the LICENSE file or the header above."
echo "==============================================================="
