import Carbon

/// Maps characters to virtual key codes using the active keyboard layout.
/// Virtual key codes identify physical key positions, so hardcoded kVK_ANSI_*
/// constants point at the wrong keys on non-US layouts (e.g. QWERTZ, AZERTY).
enum KeyCodeResolver {
    /// Returns the key code of the first character that exists as an
    /// unshifted key on the current layout.
    static func keyCode(forAnyOf characters: [Character]) -> UInt32? {
        for character in characters {
            if let code = keyCode(for: character) { return code }
        }
        return nil
    }

    static func keyCode(for character: Character) -> UInt32? {
        guard let source = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
              let layoutDataRef = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData) else {
            return nil
        }
        let layoutData = Unmanaged<CFData>.fromOpaque(layoutDataRef).takeUnretainedValue() as Data

        return layoutData.withUnsafeBytes { buffer -> UInt32? in
            guard let layout = buffer.baseAddress?.assumingMemoryBound(to: UCKeyboardLayout.self) else {
                return nil
            }
            for code in 0..<UInt16(128) {
                var deadKeyState: UInt32 = 0
                var chars = [UniChar](repeating: 0, count: 4)
                var length = 0
                let status = UCKeyTranslate(
                    layout,
                    code,
                    UInt16(kUCKeyActionDisplay),
                    0, // no modifiers: the unshifted character on this key
                    UInt32(LMGetKbdType()),
                    OptionBits(kUCKeyTranslateNoDeadKeysMask),
                    &deadKeyState,
                    chars.count,
                    &length,
                    &chars
                )
                if status == noErr, length > 0,
                   let scalar = Unicode.Scalar(chars[0]), Character(scalar) == character {
                    return UInt32(code)
                }
            }
            return nil
        }
    }
}
