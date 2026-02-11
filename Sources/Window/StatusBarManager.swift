import AppKit
import os.log

/// 系统托盘管理器
/// 负责状态栏图标和右键菜单
@MainActor
final class StatusBarManager {
    private static let logger = Logger(subsystem: Constants.logSubsystem, category: "StatusBar")
    
    /// 状态栏图标
    private var statusItem: NSStatusItem?
    
    /// 窗口切换回调
    private let onToggleWindow: () -> Void
    
    /// 清空历史回调
    private let onClearHistory: () -> Void
    
    init(onToggleWindow: @escaping () -> Void, onClearHistory: @escaping () -> Void) {
        self.onToggleWindow = onToggleWindow
        self.onClearHistory = onClearHistory
    }
    
    /// 初始化状态栏
    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "eye.circle.fill", accessibilityDescription: "焦点追踪器")
        }
        
        buildMenu()
        Self.logger.info("📌 托盘图标已创建")
    }
    
    /// 构建右键菜单
    private func buildMenu() {
        let menu = NSMenu()
        
        let toggleItem = NSMenuItem(title: "显示/隐藏窗口", action: #selector(handleToggle), keyEquivalent: "w")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        menu.addItem(.separator())
        
        let clearItem = NSMenuItem(title: "清空记录", action: #selector(handleClear), keyEquivalent: "c")
        clearItem.target = self
        menu.addItem(clearItem)
        
        menu.addItem(.separator())
        
        let quitItem = NSMenuItem(title: "退出", action: #selector(handleQuit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func handleToggle() {
        onToggleWindow()
    }
    
    @objc private func handleClear() {
        onClearHistory()
    }
    
    @objc private func handleQuit() {
        NSApp.terminate(nil)
    }
}
