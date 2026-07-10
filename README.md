# Mac Window Manager

A tiny, keyboard-only window manager for macOS, with the same window
management actions as Raycast (halves, quarters, thirds, maximize, center,
multi-display moves, restore). No UI except a menu bar icon to quit.

~500 lines of Swift, no dependencies.

## Build & run

Requires macOS 13+ and Xcode command line tools.

```sh
swift build -c release
.build/release/WindowManager
```

On first launch, macOS asks you to grant **Accessibility** permission
(System Settings → Privacy & Security → Accessibility). Grant it and relaunch.

## Run in the background / start at login

```sh
./scripts/install.sh
```

This builds the app, installs it to `~/.local/bin/window-manager`, and
registers a LaunchAgent so it runs without a terminal, starts at login, and
restarts if it crashes. To remove everything: `./scripts/uninstall.sh`.

After changing shortcuts or pulling updates, rerun `./scripts/install.sh`.

> **Note:** macOS ties the Accessibility grant to the binary's content, so
> every install/update invalidates it. After each install, toggle
> `window-manager` off and on in System Settings → Privacy & Security →
> Accessibility (the script opens that pane for you), then restart it:
> `launchctl kickstart -k gui/$(id -u)/com.local.window-manager`

## Shortcuts

All shortcuts use **⌃⌥** (Control + Option) as the base modifier.

| Action | Shortcut |
|---|---|
| Left / Right half | ⌃⌥ ← / ⌃⌥ → |
| Top / Bottom half | ⌃⌥ ↑ / ⌃⌥ ↓ |
| Quarters (TL / TR / BL / BR) | ⌃⌥ U / I / J / K |
| First / Center / Last third | ⌃⌥ D / F / G |
| First / Last two-thirds | ⌃⌥ E / T |
| Maximize | ⌃⌥ ↩ |
| Almost maximize (90%) | ⌃⌥ Space |
| Maximize height / width | ⌃⌥⇧ ↑ / ⌃⌥⇧ → |
| Center window | ⌃⌥ C |
| Grow / shrink by 10% of screen (25%–100%) | ⌃⌥ + / ⌃⌥ - |
| Next / Previous display | ⌃⌥⌘ → / ⌃⌥⌘ ← |
| Restore previous size | ⌃⌥ ⌫ |

To change a shortcut, edit the table in
`Sources/WindowManager/Keybindings.swift` and rebuild.

## How it works

- **Window control:** the Accessibility API (`AXUIElement`) reads and sets
  the frame of the focused window — `WindowManager.swift`.
- **Shortcuts:** Carbon `RegisterEventHotKey` registers global hotkeys
  without needing an event tap or Input Monitoring — `HotkeyManager.swift`.
- **Layout math:** each action computes a target rect from the screen's
  visible frame — `WindowAction.swift`.
