# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an AeroSpace tiling window manager configuration for macOS. The main config file is `aerospace.toml` (TOML format, config-version 2).

## Key Architecture

- **`aerospace.toml`** — Main config, loaded from `~/.config/aerospace/aerospace.toml` (symlinked from `~/mac-initial-setup`). Do not also create `~/.aerospace.toml` — AeroSpace errors when both exist. Uses vim-style navigation (alt+hjkl) and has two binding modes: `main` and `service` (entered via alt+shift+semicolon).
- **`scripts/center-window.js`** — JXA (JavaScript for Automation) script that centers the focused floating window on its current monitor. Invoked from service mode via `c` key.
- **Sketchybar integration** — `exec-on-workspace-change` sends workspace events to sketchybar for status bar display.

## Applying Changes

Reload config from within AeroSpace: enter service mode (`alt+shift+;`), then press `esc`.

Or from terminal:
```sh
aerospace reload-config
```

## Binding Modes

- **main**: Default mode. alt+hjkl for focus, alt+shift+hjkl for move, alt+1-9 for workspaces.
- **service**: Entered via `alt+shift+;`. Provides: reset layout (`r`), toggle float (`f`), center window (`c`), close other windows (`backspace`), join-with (`alt+shift+hjkl`). All commands auto-return to main mode.

## Config Reference

AeroSpace docs: https://nikitabobko.github.io/AeroSpace/commands
