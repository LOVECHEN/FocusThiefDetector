import AppKit
import SwiftUI
import os.log

/// 悬浮窗口管理器
/// 负责窗口的创建、配置、显隐和位置持久化
@MainActor
final class FloatingWindowManager: NSObject, NSWindowDelegate {
    private static let logger = Logger(subsystem: Constants.logSubsystem, category: "Window")
    
    /// 悬浮窗口实例
    private(set) var window: NSWindow!
    
    /// 创建并显示悬浮窗口
    func setup(with contentView: some View) {
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let windowX = screenFrame.maxX - Constants.windowWidth - 20
        let windowY = screenFrame.maxY - Constants.windowHeight - 20
        
        window = NSWindow(
            contentRect: NSRect(x: windowX, y: windowY, width: Constants.windowWidth, height: Constants.windowHeight),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        // 窗口属性
        window.level = .floating
        window.title = "🔍 焦点追踪器"
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.95)
        
        // 宽度固定，高度可调
        window.minSize = NSSize(width: Constants.windowWidth, height: Constants.windowMinHeight)
        window.maxSize = NSSize(width: Constants.windowWidth, height: Constants.windowMaxHeight)
        
        // 位置持久化
        window.setFrameAutosaveName(Constants.windowAutosaveName)
        
        // 内容视图
        window.contentView = NSHostingView(rootView: contentView)
        
        // 关闭按钮只隐藏不退出
        window.delegate = self
        
        // 显示
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        Self.logger.info("📍 悬浮窗口已创建")
    }
    
    /// 切换窗口可见性
    func toggle() {
        guard let window = window else { return }
        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    // MARK: - NSWindowDelegate
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        return false
    }
}
