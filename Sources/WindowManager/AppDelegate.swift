import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let windowManager = WindowManager()
    private let hotkeys = HotkeyManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        ensureAccessibilityPermission()
        setUpStatusItem()
        registerHotkeys()
    }

    private func ensureAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        if !AXIsProcessTrustedWithOptions(options) {
            NSLog("Waiting for Accessibility permission. Grant it in System Settings > Privacy & Security > Accessibility, then relaunch.")
        }
    }

    private func setUpStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(systemSymbolName: "macwindow.on.rectangle", accessibilityDescription: "Window Manager")

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Window Manager", action: nil, keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        item.menu = menu
        statusItem = item
    }

    private func registerHotkeys() {
        for binding in Keybindings.defaults {
            hotkeys.register(keyCode: binding.keyCode, modifiers: binding.modifiers) { [weak self] in
                self?.windowManager.perform(binding.action)
            }
        }
    }
}
