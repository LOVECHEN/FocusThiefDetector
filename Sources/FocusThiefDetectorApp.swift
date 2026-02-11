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

/// 应用代理 - 轻量编排层
/// 职责：连接 Monitor、Window、StatusBar 三大组件
class AppDelegate: NSObject, NSApplicationDelegate {
    private static let logger = Logger(subsystem: Constants.logSubsystem, category: "App")
    
    private var monitor: FocusMonitor!
    private var windowManager: FloatingWindowManager!
    private var statusBarManager: StatusBarManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 隐藏 Dock 图标
        NSApp.setActivationPolicy(.accessory)
        
        // 初始化核心监控器
        monitor = FocusMonitor()
        
        // 初始化窗口管理器
        windowManager = FloatingWindowManager()
        windowManager.setup(with: ContentView(monitor: monitor))
        
        // 初始化托盘（通过回调解耦）
        statusBarManager = StatusBarManager(
            onToggleWindow: { [weak self] in self?.windowManager.toggle() },
            onClearHistory: { [weak self] in
                Task { @MainActor in self?.monitor.clearHistory() }
            }
        )
        statusBarManager.setup()
        
        // 启动监控
        Task { @MainActor in
            monitor.startMonitoring()
        }
        
        // 检查权限
        PermissionChecker.checkAccessibility()
        
        Self.logger.info("🚀 焦点追踪器已启动")
    }
}
