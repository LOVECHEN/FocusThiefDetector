import Foundation

/// 日期格式化工具 - 共享 DateFormatter 避免重复创建
enum DateFormatting {
    /// 时间格式化器（HH:mm:ss）
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
    
    /// 格式化时间为 HH:mm:ss
    static func formatTime(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }
}
