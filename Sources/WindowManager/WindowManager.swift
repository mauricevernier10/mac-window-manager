import AppKit
import ApplicationServices

/// Moves and resizes the frontmost window via the Accessibility API.
/// All geometry is done in AX coordinates: origin at the top-left of the
/// primary screen, y increasing downwards.
final class WindowManager {
    /// Frame of the last window we changed, before the change, so `.restore`
    /// can undo the most recent action.
    private var lastChange: (window: AXUIElement, frame: CGRect)?

    func perform(_ action: WindowAction) {
        guard let window = focusedWindow(), let windowFrame = frame(of: window) else {
            NSSound.beep()
            return
        }
        guard let screen = axVisibleFrameOfScreen(containing: windowFrame) else { return }

        let target: CGRect?
        switch action {
        case .restore:
            target = lastChange.flatMap { CFEqual($0.window, window) ? $0.frame : nil }
        case .nextDisplay:
            target = frameOnAdjacentDisplay(windowFrame: windowFrame, currentScreen: screen, offset: 1)
        case .previousDisplay:
            target = frameOnAdjacentDisplay(windowFrame: windowFrame, currentScreen: screen, offset: -1)
        default:
            target = action.targetFrame(window: windowFrame, screen: screen)
        }

        guard let target, target != windowFrame else { return }
        lastChange = (window, windowFrame)
        setFrame(target, for: window)
    }

    // MARK: - Display moves

    private func frameOnAdjacentDisplay(windowFrame: CGRect, currentScreen: CGRect, offset: Int) -> CGRect? {
        let screens = NSScreen.screens.map(axVisibleFrame(of:))
        guard screens.count > 1, let index = screens.firstIndex(of: currentScreen) else { return nil }
        let next = screens[(index + offset + screens.count) % screens.count]

        // Keep the window's relative position and size proportional on the new screen.
        let relX = (windowFrame.minX - currentScreen.minX) / currentScreen.width
        let relY = (windowFrame.minY - currentScreen.minY) / currentScreen.height
        let relW = windowFrame.width / currentScreen.width
        let relH = windowFrame.height / currentScreen.height
        return CGRect(
            x: next.minX + relX * next.width,
            y: next.minY + relY * next.height,
            width: relW * next.width,
            height: relH * next.height
        )
    }

    // MARK: - Screens

    private func axVisibleFrame(of screen: NSScreen) -> CGRect {
        // Cocoa uses a bottom-left origin with y up; AX uses top-left with y
        // down. Flip relative to the primary screen's frame.
        let primaryHeight = NSScreen.screens[0].frame.height
        let visible = screen.visibleFrame
        return CGRect(
            x: visible.minX,
            y: primaryHeight - visible.maxY,
            width: visible.width,
            height: visible.height
        )
    }

    private func axVisibleFrameOfScreen(containing windowFrame: CGRect) -> CGRect? {
        let screens = NSScreen.screens.map(axVisibleFrame(of:))
        guard !screens.isEmpty else { return nil }
        let best = screens.max { a, b in
            a.intersection(windowFrame).area < b.intersection(windowFrame).area
        }
        return best
    }

    // MARK: - Accessibility

    private func focusedWindow() -> AXUIElement? {
        let systemWide = AXUIElementCreateSystemWide()
        var appRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(systemWide, kAXFocusedApplicationAttribute as CFString, &appRef) == .success,
              let appRef else { return nil }
        var windowRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(appRef as! AXUIElement, kAXFocusedWindowAttribute as CFString, &windowRef) == .success,
              let windowRef else { return nil }
        return (windowRef as! AXUIElement)
    }

    private func frame(of window: AXUIElement) -> CGRect? {
        var positionRef: CFTypeRef?
        var sizeRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef) == .success,
              AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef) == .success,
              let positionRef, let sizeRef else { return nil }

        var position = CGPoint.zero
        var size = CGSize.zero
        guard AXValueGetValue(positionRef as! AXValue, .cgPoint, &position),
              AXValueGetValue(sizeRef as! AXValue, .cgSize, &size) else { return nil }
        return CGRect(origin: position, size: size)
    }

    private func setFrame(_ rect: CGRect, for window: AXUIElement) {
        var position = rect.origin
        var size = rect.size
        guard let positionValue = AXValueCreate(.cgPoint, &position),
              let sizeValue = AXValueCreate(.cgSize, &size) else { return }

        // Set position, then size, then position again: some apps clamp the
        // position based on the old size, so a single pass can leave the
        // window in the wrong place.
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
        AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
    }
}

private extension CGRect {
    var area: CGFloat { isNull ? 0 : width * height }
}
