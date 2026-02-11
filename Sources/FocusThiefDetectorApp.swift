import SwiftUI
import AppKit
import os.log

/// 焦点追踪器应用入口
@main
struct FocusThiefDetectorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

/// 应用代理 - 托盘 + 悬浮窗口
class AppDelegate: NSObject, NSApplicationDelegate {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "FocusThiefDetector", category: "App")
    
    var floatingWindow: NSWindow!
    var statusItem: NSStatusItem!
    var monitor: FocusMonitor!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏Dock图标
        NSApp.setActivationPolicy(.accessory)
        
        // 创建共享的监控器
        monitor = FocusMonitor()
        
        // 创建托盘图标
        setupStatusBar()
        
        // 创建悬浮窗口
        createFloatingWindow()
        
        // 启动监控
        Task { @MainActor in
            monitor.startMonitoring()
        }
        
        // 检查辅助功能权限
        checkAccessibilityPermission()
        
        Self.logger.info("🚀 焦点追踪器已启动")
    }
    
    /// 设置托盘图标
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "eye.circle.fill", accessibilityDescription: "焦点追踪器")
        }
        
        // 创建菜单
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "显示/隐藏窗口", action: #selector(toggleWindow), keyEquivalent: "w"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "清空记录", action: #selector(clearHistory), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quitApp), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    
    @objc func toggleWindow() {
        if floatingWindow.isVisible {
            floatingWindow.orderOut(nil)
        } else {
            floatingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    @objc func clearHistory() {
        Task { @MainActor in
            monitor.clearHistory()
        }
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
    
    /// 检查辅助功能权限
    private func checkAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !trusted {
            Self.logger.warning("⚠️ 需要辅助功能权限才能完整监控焦点切换")
        } else {
            Self.logger.info("✅ 辅助功能权限已获取")
        }
    }
    
    /// 创建悬浮窗口
    func createFloatingWindow() {
        let contentView = ContentView(monitor: monitor)
        
        // 固定窗口尺寸
        let windowWidth: CGFloat = 300
        let windowHeight: CGFloat = 360
        
        // 计算窗口位置：屏幕右上角
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        let windowX = screenFrame.maxX - windowWidth - 20
        let windowY = screenFrame.maxY - windowHeight - 20
        
        floatingWindow = NSWindow(
            contentRect: NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],  // 保留resizable
            backing: .buffered,
            defer: false
        )
        
        // 窗口属性配置
        floatingWindow.level = .floating                    // 始终置顶
        floatingWindow.title = "🔍 焦点追踪器"
        floatingWindow.titlebarAppearsTransparent = true
        floatingWindow.isMovableByWindowBackground = true   // 可拖拽
        floatingWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        floatingWindow.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.95)
        
        // 🔒 宽度固定，高度可调
        floatingWindow.minSize = NSSize(width: windowWidth, height: 150)
        floatingWindow.maxSize = NSSize(width: windowWidth, height: 800)
        
        // 窗口位置持久化：重启后自动恢复上次位置
        floatingWindow.setFrameAutosaveName("FocusThiefDetectorMainWindow")
        
        // 设置内容视图
        floatingWindow.contentView = NSHostingView(rootView: contentView)
        
        // 关闭窗口时只是隐藏，不退出
        floatingWindow.delegate = self
        
        // 显示窗口
        floatingWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        Self.logger.info("📍 悬浮窗口已创建，尺寸: \(Int(windowWidth))x\(Int(windowHeight))")
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // 点关闭按钮只是隐藏窗口，不退出应用
        sender.orderOut(nil)
        return false
    }
}
