import CoreGraphics

enum WindowAction {
    case leftHalf
    case rightHalf
    case topHalf
    case bottomHalf

    case topLeftQuarter
    case topRightQuarter
    case bottomLeftQuarter
    case bottomRightQuarter

    case firstThird
    case centerThird
    case lastThird
    case firstTwoThirds
    case lastTwoThirds

    case maximize
    case almostMaximize
    case maximizeHeight
    case maximizeWidth
    case center

    case makeLarger
    case makeSmaller

    case nextDisplay
    case previousDisplay
    case restore

    /// Computes the target frame for this action. `screen` is the visible
    /// frame of the screen the window is on, and `window` is the window's
    /// current frame. Both are in AX (top-left origin) coordinates.
    /// Returns nil for actions that don't resolve to a frame on the current
    /// screen (display moves and restore are handled by the caller).
    func targetFrame(window: CGRect, screen: CGRect) -> CGRect? {
        let resizeStep: CGFloat = 60
        let halfW = screen.width / 2
        let halfH = screen.height / 2
        let thirdW = screen.width / 3

        switch self {
        case .leftHalf:
            return CGRect(x: screen.minX, y: screen.minY, width: halfW, height: screen.height)
        case .rightHalf:
            return CGRect(x: screen.midX, y: screen.minY, width: halfW, height: screen.height)
        case .topHalf:
            return CGRect(x: screen.minX, y: screen.minY, width: screen.width, height: halfH)
        case .bottomHalf:
            return CGRect(x: screen.minX, y: screen.midY, width: screen.width, height: halfH)

        case .topLeftQuarter:
            return CGRect(x: screen.minX, y: screen.minY, width: halfW, height: halfH)
        case .topRightQuarter:
            return CGRect(x: screen.midX, y: screen.minY, width: halfW, height: halfH)
        case .bottomLeftQuarter:
            return CGRect(x: screen.minX, y: screen.midY, width: halfW, height: halfH)
        case .bottomRightQuarter:
            return CGRect(x: screen.midX, y: screen.midY, width: halfW, height: halfH)

        case .firstThird:
            return CGRect(x: screen.minX, y: screen.minY, width: thirdW, height: screen.height)
        case .centerThird:
            return CGRect(x: screen.minX + thirdW, y: screen.minY, width: thirdW, height: screen.height)
        case .lastThird:
            return CGRect(x: screen.maxX - thirdW, y: screen.minY, width: thirdW, height: screen.height)
        case .firstTwoThirds:
            return CGRect(x: screen.minX, y: screen.minY, width: thirdW * 2, height: screen.height)
        case .lastTwoThirds:
            return CGRect(x: screen.maxX - thirdW * 2, y: screen.minY, width: thirdW * 2, height: screen.height)

        case .maximize:
            return screen
        case .almostMaximize:
            let scaled = CGSize(width: screen.width * 0.9, height: screen.height * 0.9)
            return CGRect(origin: CGPoint(x: screen.midX - scaled.width / 2, y: screen.midY - scaled.height / 2), size: scaled)
        case .maximizeHeight:
            return CGRect(x: window.minX, y: screen.minY, width: window.width, height: screen.height)
        case .maximizeWidth:
            return CGRect(x: screen.minX, y: window.minY, width: screen.width, height: window.height)
        case .center:
            return CGRect(x: screen.midX - window.width / 2, y: screen.midY - window.height / 2, width: window.width, height: window.height)

        case .makeLarger:
            return window.insetBy(dx: -resizeStep, dy: -resizeStep).clamped(to: screen)
        case .makeSmaller:
            let shrunk = window.insetBy(dx: resizeStep, dy: resizeStep)
            return shrunk.width > 200 && shrunk.height > 200 ? shrunk : window

        case .nextDisplay, .previousDisplay, .restore:
            return nil
        }
    }
}

extension CGRect {
    /// Clamps the rect so it fits inside `bounds`, shrinking it if necessary.
    func clamped(to bounds: CGRect) -> CGRect {
        var rect = self
        rect.size.width = min(rect.width, bounds.width)
        rect.size.height = min(rect.height, bounds.height)
        rect.origin.x = max(bounds.minX, min(rect.minX, bounds.maxX - rect.width))
        rect.origin.y = max(bounds.minY, min(rect.minY, bounds.maxY - rect.height))
        return rect
    }
}
