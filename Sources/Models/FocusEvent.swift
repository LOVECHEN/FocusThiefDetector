import Foundation

/// 焦点切换事件数据模型
struct FocusEvent: Identifiable {
    let id = UUID()
    let timestamp: Date
    let appName: String
    let bundleIdentifier: String?
    let processIdentifier: pid_t
    let timeSinceLast: TimeInterval?
    
    /// 可疑判定阈值（从 FocusMonitor 传入）
    let suspiciousThreshold: TimeInterval
    
    /// 判断是否为"可疑"的焦点抢夺
    var isSuspicious: Bool {
        guard let interval = timeSinceLast else { return false }
        return interval < suspiciousThreshold
    }
    
    /// 获取显示用的 emoji 图标（真实图标不可用时的回退）
    var iconName: String {
        if isSuspicious { return "🔴" }
        guard let bid = bundleIdentifier else { return "⚪" }
        
        switch true {
        case bid.contains("com.apple"):    return "🔵"
        case bid.contains("com.tencent"):  return "🟡"
        case bid.contains("com.microsoft"):return "🟣"
        case bid.contains("com.google"):   return "🟠"
        default:                           return "🟢"
        }
    }
    
    /// 格式化的时间戳字符串（使用共享 Formatter）
    var formattedTime: String {
        DateFormatting.formatTime(timestamp)
    }
}
