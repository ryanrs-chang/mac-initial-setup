---
name: aerospace-config
description: This skill should be used when the user asks to edit, modify, or understand their AeroSpace tiling window manager configuration, mentions "aerospace", "window management", "key binding", "workspace", "tiling layout", "window rule", or discusses macOS window tiling setup.
version: 1.0.0
---

# AeroSpace Configuration Skill

## Config Location

The AeroSpace config file is at: `~/.config/aerospace/aerospace.toml` (symlink to `~/mac-initial-setup/config/aerospace/aerospace.toml`)

Format: TOML (version 2)

## Core Concepts

### Tree Structure
- Windows and containers form a hierarchical tree per workspace
- Containers hold children; windows are leaf nodes only
- Each container has a **layout** (tiles/accordion) and **orientation** (horizontal/vertical)

### Layouts
| Layout | Description |
|--------|-------------|
| `h_tiles` | Side-by-side horizontally |
| `v_tiles` | Stacked vertically |
| `h_accordion` | Horizontal stack with padding showing adjacent |
| `v_accordion` | Vertical stack with padding showing adjacent |

### Key Binding Syntax
```toml
[mode.main.binding]
    alt-h = 'focus left'
    alt-shift-j = 'move down'
    alt-1 = 'workspace 1'
    # Chained commands
    alt-r = ['mode resize', 'exec-and-forget notify']
```

**Modifiers:** cmd, alt, ctrl, shift
**Keys:** a-z, 0-9, F1-F24, space, enter, tab, arrows, minus, equal, slash, comma, semicolon, backspace, etc.

### Binding Modes
```toml
[mode.main.binding]
    alt-r = 'mode resize'

[mode.resize.binding]
    minus = 'resize smart -50'
    equal = 'resize smart +50'
    esc = 'mode main'
```

### Window Detection Rules
```toml
[[on-window-detected]]
    if.app-id = 'com.apple.Terminal'
    run = 'move-node-to-workspace T'

[[on-window-detected]]
    if.app-name-regex-substring = 'Slack'
    if.window-title-regex-substring = 'Huddle'
    run = ['layout floating', 'move-node-to-workspace S']
```

**Available conditions:**
- `if.app-id` - Bundle identifier (e.g., `com.apple.Safari`)
- `if.app-name-regex-substring` - App name regex match
- `if.window-title-regex-substring` - Window title regex match
- `if.workspace` - Current workspace
- `if.during-aerospace-startup` - Only during startup

### Workspace-to-Monitor Assignment
```toml
[workspace-to-monitor-force-assignment]
    1 = 'main'
    2 = 'secondary'
    3 = '^built-in.*'  # regex pattern
```

### Callbacks
```toml
on-focus-changed = ['move-mouse window-lazy-center']
on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
exec-on-workspace-change = ['/bin/bash', '-c', 'echo $AEROSPACE_FOCUSED_WORKSPACE']
```

## Common Operations

When adding new configuration, always:
1. Read the current config first
2. Follow existing style and indentation
3. Place new entries in the appropriate TOML section
4. Use the reference guide at `references/guide.md` for detailed syntax

## Reference
See `references/guide.md` for the complete AeroSpace guide with all options and examples.
