# AeroSpace Complete Guide Reference

## Configuration File

- Location: `~/.aerospace.toml` or `${XDG_CONFIG_HOME}/aerospace/aerospace.toml`
- Format: TOML
- Scalar values fall back to defaults; vector/array values default to empty unless configured

## Tree Structure

- Each workspace has a single root node
- Containers hold arbitrary children; windows are leaf nodes only
- Every container has a layout and orientation
- Two normalizations (enabled by default):
  - Single-child containers flatten (root exception allows one window child)
  - Nested containers must have opposite orientations

```toml
enable-normalization-flatten-containers = true
enable-normalization-opposite-orientation-for-nested-containers = true
```

## Layouts

### Tiles
- `h_tiles` - Horizontal side-by-side
- `v_tiles` - Vertical stacked
- Adjustable sizing per window

### Accordion
- `h_accordion` - Horizontal stack with padding
- `v_accordion` - Vertical stack with padding
- Padding configured via `accordion-padding` (default: 30 pixels)

```toml
default-root-container-layout = 'tiles'
default-root-container-orientation = 'auto'
accordion-padding = 30
```

## Key Bindings

### Syntax
```toml
[mode.main.binding]
    modifier-key = 'command arg1 arg2'
    modifier-key = ['command1', 'command2']  # chained commands
```

### Modifiers
`cmd`, `alt`, `ctrl`, `shift` — combine with `-` (e.g., `alt-shift-h`)

### Keys
- Letters: `a` through `z`
- Numbers: `0` through `9`
- Function keys: `f1` through `f24`
- Special: `space`, `enter`, `tab`, `backspace`, `esc`
- Arrows: `left`, `right`, `up`, `down`
- Symbols: `minus`, `equal`, `slash`, `comma`, `period`, `semicolon`, `quote`, `leftSquareBracket`, `rightSquareBracket`, `backslash`

### Binding Modes
Switch between different keybinding contexts (like i3 modes):

```toml
[mode.main.binding]
    alt-r = 'mode resize'

[mode.resize.binding]
    minus = 'resize smart -50'
    equal = 'resize smart +50'
    enter = 'mode main'
    esc = 'mode main'
```

## Commands Reference

### Focus & Movement
- `focus <left|right|up|down>` - Move focus
- `move <left|right|up|down>` - Move window
- `move-node-to-workspace <name>` - Move to workspace

### Layout
- `layout <h_tiles|v_tiles|h_accordion|v_accordion|tiles|accordion|horizontal|vertical|tiling|floating>` - Set layout
- `layout floating` / `layout tiling` - Toggle float
- `split <horizontal|vertical>` - Split container

### Resize
- `resize smart <+N|-N>` - Smart resize by N pixels
- `resize <width|height> <+N|-N>` - Resize specific dimension

### Workspace
- `workspace <name>` - Switch to workspace
- `workspace-back-and-forth` - Toggle previous workspace
- `move-workspace-to-monitor <next|prev>` - Move workspace

### Other
- `mode <name>` - Switch binding mode
- `close` - Close focused window
- `close-all-windows-but-current` - Close all except focused
- `flatten-workspace-tree` - Reset workspace layout
- `reload-config` - Reload configuration
- `exec-and-forget <command>` - Run shell command (fire and forget)

## Window Detection (on-window-detected)

### Syntax
```toml
[[on-window-detected]]
    if.app-id = 'com.example.App'
    run = 'move-node-to-workspace A'
```

### Conditions
| Condition | Description | Example |
|-----------|-------------|---------|
| `if.app-id` | Bundle ID (exact match) | `'com.apple.Safari'` |
| `if.app-name-regex-substring` | App name regex | `'Firefox'` |
| `if.window-title-regex-substring` | Window title regex | `'Settings'` |
| `if.workspace` | Current workspace | `'1'` |
| `if.during-aerospace-startup` | Only at startup | `true` |

### Multiple Conditions
All conditions are AND-ed together:
```toml
[[on-window-detected]]
    if.app-id = 'com.tinyspeck.slackmacgap'
    if.window-title-regex-substring = 'Huddle'
    run = 'layout floating'
```

### Multiple Commands
```toml
[[on-window-detected]]
    if.app-id = 'com.spotify.client'
    run = ['layout floating', 'move-node-to-workspace M']
```

### Common App IDs
- Safari: `com.apple.Safari`
- Terminal: `com.apple.Terminal`
- Finder: `com.apple.finder`
- Slack: `com.tinyspeck.slackmacgap`
- VS Code: `com.microsoft.VSCode`
- Chrome: `com.google.Chrome`
- Firefox: `org.mozilla.firefox`
- iTerm2: `com.googlecode.iterm2`
- Spotify: `com.spotify.client`
- Discord: `com.hnc.Discord`

To find an app's bundle ID: `osascript -e 'id of app "AppName"'`

## Workspace Configuration

### Persistent Workspaces
Keep workspaces alive even when empty:
```toml
[persistent-workspaces]
    1 = ''
    2 = ''
```

### Workspace-to-Monitor Assignment
```toml
[workspace-to-monitor-force-assignment]
    1 = 'main'
    2 = 'secondary'
    W = '^built-in.*'  # regex pattern
```

Monitor identifiers: `main`, `secondary`, numeric index, or regex pattern.

## Gaps

```toml
[gaps]
    inner.horizontal = 5
    inner.vertical = 5
    outer.left = 5
    outer.right = 5
    outer.bottom = 5
    outer.top = 45  # larger for menu bar
```

## Callbacks

```toml
# Mouse follows focus
on-focus-changed = ['move-mouse window-lazy-center']
on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

# Custom script on workspace change
exec-on-workspace-change = ['/bin/bash', '-c', 'echo $AEROSPACE_FOCUSED_WORKSPACE']
```

### Available Environment Variables
- `$AEROSPACE_FOCUSED_WORKSPACE` - Current workspace name
- `$AEROSPACE_PREV_WORKSPACE` - Previous workspace name

## Floating Windows

- Floating windows integrate with focus navigation
- The smallest tiling container containing a floating window's center becomes its parent for focus
- Windows without fullscreen buttons auto-float (dialog heuristic)
- Override with `on-window-detected` if needed

## Keyboard Layout Support

```toml
[key-mapping]
    preset = 'qwerty'  # or 'dvorak', 'colemak'

[key-mapping.key-notation-to-key-code]
    custom-key = 'u'
```

## Environment Variables for Exec

```toml
[exec]
    inherit-env-vars = true

[exec.env-vars]
    PATH = '/opt/homebrew/bin:${PATH}'
```

## Startup Commands

```toml
after-startup-command = ['exec-and-forget /path/to/script']
```

## Multi-Monitor Tips

- Arrange monitors so each has free space in bottom corners (for hidden windows)
- Consider: `defaults write com.apple.spaces spans-displays -bool true` for stability
- Use `move-workspace-to-monitor` to shift workspaces between screens
