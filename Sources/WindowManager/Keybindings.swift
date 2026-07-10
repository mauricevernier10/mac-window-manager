import Carbon

struct Keybinding {
    let action: WindowAction
    let keyCode: UInt32
    let modifiers: UInt32
}

/// Default shortcuts. Edit this table to customize — key codes are the
/// standard macOS virtual key codes (kVK_*).
enum Keybindings {
    private static let hyper = UInt32(controlKey | optionKey)
    private static let hyperShift = UInt32(controlKey | optionKey | shiftKey)
    private static let hyperCmd = UInt32(controlKey | optionKey | cmdKey)

    static var defaults: [Keybinding] {
        // Resolve the +/- keys from the active keyboard layout: their
        // physical positions differ between layouts (US, QWERTZ, AZERTY, ...).
        // On US layouts "+" is shift+"=", so "=" is the unshifted fallback.
        let plusKey = KeyCodeResolver.keyCode(forAnyOf: ["+", "="]) ?? UInt32(kVK_ANSI_Equal)
        let minusKey = KeyCodeResolver.keyCode(forAnyOf: ["-"]) ?? UInt32(kVK_ANSI_Minus)
        return staticBindings + [
            Keybinding(action: .makeLarger, keyCode: plusKey, modifiers: hyper),
            Keybinding(action: .makeSmaller, keyCode: minusKey, modifiers: hyper),
        ]
    }

    private static let staticBindings: [Keybinding] = [
        // Halves: ⌃⌥ + arrows
        Keybinding(action: .leftHalf, keyCode: UInt32(kVK_LeftArrow), modifiers: hyper),
        Keybinding(action: .rightHalf, keyCode: UInt32(kVK_RightArrow), modifiers: hyper),
        Keybinding(action: .topHalf, keyCode: UInt32(kVK_UpArrow), modifiers: hyper),
        Keybinding(action: .bottomHalf, keyCode: UInt32(kVK_DownArrow), modifiers: hyper),

        // Quarters: ⌃⌥ + U / I / J / K
        Keybinding(action: .topLeftQuarter, keyCode: UInt32(kVK_ANSI_U), modifiers: hyper),
        Keybinding(action: .topRightQuarter, keyCode: UInt32(kVK_ANSI_I), modifiers: hyper),
        Keybinding(action: .bottomLeftQuarter, keyCode: UInt32(kVK_ANSI_J), modifiers: hyper),
        Keybinding(action: .bottomRightQuarter, keyCode: UInt32(kVK_ANSI_K), modifiers: hyper),

        // Thirds: ⌃⌥ + D / F / G, two-thirds: ⌃⌥ + E / T
        Keybinding(action: .firstThird, keyCode: UInt32(kVK_ANSI_D), modifiers: hyper),
        Keybinding(action: .centerThird, keyCode: UInt32(kVK_ANSI_F), modifiers: hyper),
        Keybinding(action: .lastThird, keyCode: UInt32(kVK_ANSI_G), modifiers: hyper),
        Keybinding(action: .firstTwoThirds, keyCode: UInt32(kVK_ANSI_E), modifiers: hyper),
        Keybinding(action: .lastTwoThirds, keyCode: UInt32(kVK_ANSI_T), modifiers: hyper),

        // Maximize & center
        Keybinding(action: .maximize, keyCode: UInt32(kVK_Return), modifiers: hyper),
        Keybinding(action: .almostMaximize, keyCode: UInt32(kVK_Space), modifiers: hyper),
        Keybinding(action: .maximizeHeight, keyCode: UInt32(kVK_UpArrow), modifiers: hyperShift),
        Keybinding(action: .maximizeWidth, keyCode: UInt32(kVK_RightArrow), modifiers: hyperShift),
        Keybinding(action: .center, keyCode: UInt32(kVK_ANSI_C), modifiers: hyper),

        // Displays: ⌃⌥⌘ + arrows
        Keybinding(action: .nextDisplay, keyCode: UInt32(kVK_RightArrow), modifiers: hyperCmd),
        Keybinding(action: .previousDisplay, keyCode: UInt32(kVK_LeftArrow), modifiers: hyperCmd),

        // Restore previous frame
        Keybinding(action: .restore, keyCode: UInt32(kVK_Delete), modifiers: hyper),
    ]
}
