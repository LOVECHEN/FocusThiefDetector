import Foundation

/// 焦点切换事件数据模型
struct FocusEvent: Identifiable, Equatable {
    let id = UUID()
    let timestamp: Date
    let appName: String
    let bundleIdentifier: String?
    let processIdentifier: pid_t
    let timeSinceLast: TimeInterval?
    
    /// 判断是否为"可疑"的焦点抢夺
    /// 规则：距离上次切换小于1秒，且不是用户常用应用
    var isSuspicious: Bool {
        guard let interval = timeSinceLast else { return false }
        return interval < 1.0
    }
    
    /// 获取显示用的应用图标名称
    var iconName: String {
        if isSuspicious {
            return "🔴"
        }
        // 根据应用类型返回不同颜色
        switch bundleIdentifier {
        case let id where id?.contains("apple") == true:
            return "🔵"
        case let id where id?.contains("com.tencent") == true:
            return "🟡"
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
