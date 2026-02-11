import SwiftUI

/// 主界面视图
struct ContentView: View {
    @ObservedObject var monitor: FocusMonitor
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            eventListView
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 标题栏
    
    private var headerView: some View {
        HStack {
            Image(systemName: "eye.fill")
                .foregroundStyle(.blue)
            
            Text("焦点追踪器")
                .font(.system(size: 13, weight: .semibold))
            
            Spacer()
            
            Text(monitor.currentApp)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: 80)
            
            Text("\(monitor.events.count)/\(Constants.maxEvents)")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(.tertiary)
            
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
    
    // MARK: - 事件列表
    
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
    
    // MARK: - 空状态
    
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

#Preview {
    ContentView(monitor: FocusMonitor())
        .frame(width: 300, height: 400)
}
