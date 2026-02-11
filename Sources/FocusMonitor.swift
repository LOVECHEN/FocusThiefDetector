import Foundation
import AppKit
import Combine

/// 焦点监控器 - 核心逻辑
/// 监听系统应用焦点切换事件并记录历史
@MainActor
class FocusMonitor: ObservableObject {
    /// 焦点事件历史记录（最新的在前面）
    @Published private(set) var events: [FocusEvent] = []
    
    /// 当前获得焦点的应用
    @Published private(set) var currentApp: String = "未知"
    
    /// 是否正在监控
    @Published private(set) var isMonitoring: Bool = false
    
    /// 最大保留事件数量
    private let maxEvents = 50
    
    /// 上一次焦点切换的时间
    private var lastSwitchTime: Date?
    
    /// 工作区通知观察者
    private var observer: NSObjectProtocol?
    
    init() {
        // 启动时获取当前激活的应用
        if let app = NSWorkspace.shared.frontmostApplication {
            currentApp = app.localizedName ?? "未知"
        }
    }
    
    /// 开始监控焦点切换
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleAppActivation(notification)
            }
        }
        
        isMonitoring = true
        print("🔍 焦点监控已启动")
    }
    
    /// 停止监控
    func stopMonitoring() {
        if let observer = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            self.observer = nil
        }
        isMonitoring = false
        print("⏹️ 焦点监控已停止")
    }
    
    /// 清空历史记录
    func clearHistory() {
        events.removeAll()
    }
    
    /// 处理应用激活事件
    private func handleAppActivation(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }
        
        let appName = app.localizedName ?? "未知应用"
        let now = Date()
        
        // 计算距离上次切换的时间间隔
        let timeSinceLast = lastSwitchTime.map { now.timeIntervalSince($0) }
        
        // 创建焦点事件
        let event = FocusEvent(
            timestamp: now,
            appName: appName,
            bundleIdentifier: app.bundleIdentifier,
            processIdentifier: app.processIdentifier,
            timeSinceLast: timeSinceLast
        )
        
        // 更新状态
        currentApp = appName
        lastSwitchTime = now
        
        // 插入到列表开头
        events.insert(event, at: 0)
        
        // 限制列表大小
        if events.count > maxEvents {
            events.removeLast()
        }
        
        // 如果是可疑切换，打印警告
        if event.isSuspicious {
            print("⚠️ 可疑焦点抢夺: \(appName) (间隔: \(String(format: "%.2f", timeSinceLast ?? 0))s)")
        }
    }
    
    deinit {
        if let observer = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }
}
