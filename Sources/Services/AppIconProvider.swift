import AppKit

/// 应用图标缓存提供者
/// 避免每次 SwiftUI 渲染都重复查询 NSWorkspace（磁盘 I/O）
@MainActor
final class AppIconProvider {
    static let shared = AppIconProvider()
    
    /// bundleIdentifier → NSImage 缓存
    private var cache: [String: NSImage] = [:]
    
    private init() {}
    
    /// 获取指定 bundleIdentifier 的应用图标（带缓存）
    func icon(for bundleID: String) -> NSImage? {
        // 缓存命中
        if let cached = cache[bundleID] {
            return cached
        }
        
        // 查询系统
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            return nil
        }
        
        let image = NSWorkspace.shared.icon(forFile: appURL.path)
        cache[bundleID] = image
        return image
    }
    
    /// 清除缓存（应用卸载/更新后可能需要）
    func clearCache() {
        cache.removeAll()
    }
}
