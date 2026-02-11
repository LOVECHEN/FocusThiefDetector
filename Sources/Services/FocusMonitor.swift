import Foundation
import AppKit
import Combine
import os.log

/// 焦点监控器 - 核心业务逻辑
/// 监听系统应用焦点切换事件并维护历史记录
@MainActor
class FocusMonitor: ObservableObject {
    private static let logger = Logger(subsystem: Constants.logSubsystem, category: "Monitor")
    
    /// 焦点事件历史记录（最新的在前面）
    @Published private(set) var events: [FocusEvent] = []
    
    /// 当前获得焦点的应用
    @Published private(set) var currentApp: String = "未知"
    
    /// 是否正在监控
    @Published private(set) var isMonitoring: Bool = false
    
    /// 可疑焦点切换的时间阈值（秒）
    @Published var suspiciousThreshold: TimeInterval = Constants.defaultSuspiciousThreshold
    
    /// 自身 bundleIdentifier，用于过滤
    private let selfBundleID = Bundle.main.bundleIdentifier
    
    /// 上一次焦点切换的时间
    private var lastSwitchTime: Date?
    
    /// 工作区通知观察者
    private var observer: NSObjectProtocol?
    
    init() {
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
        Self.logger.info("🔍 焦点监控已启动")
    }
    
    /// 停止监控
    func stopMonitoring() {
        if let observer = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            self.observer = nil
        }
        isMonitoring = false
        Self.logger.info("⏹️ 焦点监控已停止")
    }
    
    /// 清空历史记录
    func clearHistory() {
        events.removeAll()
    }
    
    // MARK: - Private
    
    private func handleAppActivation(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            return
        }
        
        // 过滤自身
        if let bid = app.bundleIdentifier, bid == selfBundleID {
            return
        }
        
        let appName = app.localizedName ?? "未知应用"
        let now = Date()
        let timeSinceLast = lastSwitchTime.map { now.timeIntervalSince($0) }
        
        let event = FocusEvent(
            timestamp: now,
            appName: appName,
            bundleIdentifier: app.bundleIdentifier,
            processIdentifier: app.processIdentifier,
            timeSinceLast: timeSinceLast,
            suspiciousThreshold: suspiciousThreshold
        )
        
        currentApp = appName
        lastSwitchTime = now
        
        events.insert(event, at: 0)
        if events.count > Constants.maxEvents {
            events.removeLast()
        }
        
        // 可疑切换：日志 + 声音提醒
        if event.isSuspicious {
            Self.logger.warning("⚠️ 可疑焦点抢夺: \(appName) (间隔: \(String(format: "%.2f", timeSinceLast ?? 0))s)")
            NSSound.beep()
        }
    }
    
    deinit {
        if let observer = observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
    }
}
