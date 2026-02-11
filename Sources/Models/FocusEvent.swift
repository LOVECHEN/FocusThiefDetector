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
    /// 规则：距离上次切换小于阈值秒
    var isSuspicious: Bool {
        guard let interval = timeSinceLast else { return false }
        return interval < suspiciousThreshold
    }
    
    /// 获取显示用的应用图标
    var iconName: String {
        if isSuspicious {
            return "🔴"
        }
        // 根据 bundleIdentifier 前缀返回不同颜色
        guard let bid = bundleIdentifier else { return "⚪" }
        
        switch true {
        case bid.contains("com.apple"):
            return "🔵"
        case bid.contains("com.tencent"):
            return "🟡"
        case bid.contains("com.microsoft"):
            return "🟣"
        case bid.contains("com.google"):
            return "🟠"
        default:
            return "🟢"
        }
    }
    
    /// 格式化的时间戳字符串
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: timestamp)
    }
}
