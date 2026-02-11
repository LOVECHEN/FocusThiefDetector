import SwiftUI
import AppKit

/// 单条事件行视图
struct EventRowView: View {
    let event: FocusEvent
    
    var body: some View {
        HStack(spacing: 8) {
            // 时间戳
            Text(event.formattedTime)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary)
            
            // 应用图标
            appIconView
            
            // 应用名称
            Text(event.appName)
                .font(.system(size: 12))
                .lineLimit(1)
                .foregroundStyle(event.isSuspicious ? .red : .primary)
            
            Spacer()
            
            // 可疑切换标记
            if event.isSuspicious, let interval = event.timeSinceLast {
                suspiciousBadge(interval: interval)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(event.isSuspicious ? Color.red.opacity(0.05) : Color.clear)
    }
    
    /// 应用图标：优先真实图标，回退到 emoji
    @ViewBuilder
    private var appIconView: some View {
        if let bid = event.bundleIdentifier,
           let icon = AppIconProvider.shared.icon(for: bid) {
            Image(nsImage: icon)
                .resizable()
                .frame(width: 16, height: 16)
                .clipShape(RoundedRectangle(cornerRadius: 3))
        } else {
            Text(event.iconName)
                .font(.system(size: 10))
        }
    }
    
    /// 可疑切换时间徽章
    private func suspiciousBadge(interval: TimeInterval) -> some View {
        Text(String(format: "%.1fs", interval))
            .font(.system(size: 10, design: .monospaced))
            .foregroundStyle(.red.opacity(0.8))
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.red.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}
