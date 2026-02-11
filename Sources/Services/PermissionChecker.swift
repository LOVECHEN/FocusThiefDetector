import Foundation
import AppKit
import os.log

/// 系统权限检查工具
enum PermissionChecker {
    private static let logger = Logger(subsystem: Constants.logSubsystem, category: "Permission")
    
    /// 检查并请求辅助功能权限
    /// - Returns: 是否已获得权限
    @discardableResult
    static func checkAccessibility(prompt: Bool = true) -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: prompt]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if trusted {
            logger.info("✅ 辅助功能权限已获取")
        } else {
            logger.warning("⚠️ 需要辅助功能权限才能完整监控焦点切换")
        }
        
        return trusted
    }
}
