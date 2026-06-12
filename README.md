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

> **Tip:** macOS ties the permission to the binary, so rebuilding can reset
> it. Copy the release binary to a stable location and run it from there:
>
> ```sh
> cp .build/release/WindowManager /usr/local/bin/window-manager
> window-manager &
> ```

To start it at login, add the binary in System Settings → General →
Login Items, or wrap it in a LaunchAgent.

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
| Almost maximize (90%) | ⌃⌥ A |
| Maximize height / width | ⌃⌥⇧ ↑ / ⌃⌥⇧ → |
| Center window | ⌃⌥ C |
| Make larger / smaller | ⌃⌥ = / ⌃⌥ - |
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
