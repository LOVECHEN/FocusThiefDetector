import SwiftUI

/// 主界面视图
struct ContentView: View {
    @ObservedObject var monitor: FocusMonitor
    @State private var isExpanded = true
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            headerView
            
            // 事件列表
            eventListView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// 标题栏视图
    private var headerView: some View {
        HStack {
            Image(systemName: "eye.fill")
                .foregroundStyle(.blue)
            
            Text("焦点追踪器")
                .font(.system(size: 13, weight: .semibold))
            
            Spacer()
            
            // 当前应用指示
            Text(monitor.currentApp)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 80)
            
            // 清空按钮
            Button(action: { monitor.clearHistory() }) {
                Image(systemName: "trash")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .help("清空历史记录")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.primary.opacity(0.05))
    }
    
    /// 事件列表视图
    private var eventListView: some View {
        Group {
            if monitor.events.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(monitor.events) { event in
                            EventRowView(event: event)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }
    
    /// 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 24))
                .foregroundStyle(.tertiary)
            
            Text("等待焦点切换...")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 单条事件行视图
struct EventRowView: View {
    let event: FocusEvent
    
    var body: some View {
        HStack(spacing: 8) {
            // 时间戳
            Text(event.formattedTime)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.secondary)
            
            // 状态图标
            Text(event.iconName)
                .font(.system(size: 10))
            
            // 应用名称
            Text(event.appName)
                .font(.system(size: 12))
                .lineLimit(1)
                .foregroundStyle(event.isSuspicious ? .red : .primary)
            
            Spacer()
            
            // 如果是可疑切换，显示时间间隔
            if event.isSuspicious, let interval = event.timeSinceLast {
                Text(String(format: "%.1fs", interval))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.red.opacity(0.8))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(event.isSuspicious ? Color.red.opacity(0.05) : Color.clear)
    }
}

#Preview {
    ContentView(monitor: FocusMonitor())
        .frame(width: 300, height: 400)
}
