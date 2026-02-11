import Foundation
import AppKit

/// 全局常量集中管理
enum Constants {
    // MARK: - 事件
    
    /// 最大保留事件数量
    static let maxEvents = 50
    
    /// 默认可疑焦点切换阈值（秒）
    static let defaultSuspiciousThreshold: TimeInterval = 1.0
    
    // MARK: - 窗口
    
    /// 窗口宽度（固定）
    static let windowWidth: CGFloat = 300
    
    /// 窗口默认高度
    static let windowHeight: CGFloat = 360
    
    /// 窗口最小高度
    static let windowMinHeight: CGFloat = 150
    
    /// 窗口最大高度
    static let windowMaxHeight: CGFloat = 800
    
    /// 窗口位置持久化 key
    static let windowAutosaveName = "FocusThiefDetectorMainWindow"
    
    // MARK: - 日志
    
    /// 日志子系统标识
    static let logSubsystem = Bundle.main.bundleIdentifier ?? "FocusThiefDetector"
}
