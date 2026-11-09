#!/usr/bin/env bash
# Runs once per machine after dotfiles are linked.
set -euo pipefail
brew services start sketchybar
brew services start borders
open -a AeroSpace
# Karabiner must be restarted to pick up a relocated (symlinked) config dir.
launchctl kickstart -k "gui/$(id -u)/org.pqrs.service.agent.karabiner_console_user_server" 2>/dev/null || true
