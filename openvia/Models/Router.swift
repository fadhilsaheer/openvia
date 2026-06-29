import Cocoa
import SwiftUI
import Combine

class Router: ObservableObject {
    static let shared = Router()
    
    @AppStorage("routingRules") private var rulesData: Data = Data()
    @AppStorage("fallbackBrowserId") private var fallbackBrowserId: String = ""
    
    @Published var rules: [Rule] = [] {
        didSet {
            if let encoded = try? JSONEncoder().encode(rules) {
                rulesData = encoded
            }
        }
    }
    
    @Published var fallback: String = "" {
        didSet {
            fallbackBrowserId = fallback
        }
    }
    
    init() {
        if let decoded = try? JSONDecoder().decode([Rule].self, from: rulesData) {
            self.rules = decoded
        }
        self.fallback = fallbackBrowserId
    }
    
    func route(url: URL) {
        guard let host = url.host else {
            openFallback(url: url)
            return
        }
        
        for rule in rules {
            if rule.matches(host: host) {
                if openWithBrowser(url: url, bundleId: rule.browserId) {
                    return
                }
            }
        }
        
        openFallback(url: url)
    }
    
    private func openFallback(url: URL) {
        if !fallback.isEmpty {
            if openWithBrowser(url: url, bundleId: fallback) {
                return
            }
        }
        
        // System default fallback (ensure we don't infinitely loop if we are default)
        let ourBundleId = Bundle.main.bundleIdentifier ?? "hyfic.org.openvia"
        let defaultSysBrowser = BrowserManager.shared.defaultBrowser?.bundleId ?? "com.apple.Safari"
        let sysFallback = defaultSysBrowser == ourBundleId ? "com.apple.Safari" : defaultSysBrowser
        
        _ = openWithBrowser(url: url, bundleId: sysFallback)
    }
    
    private func openWithBrowser(url: URL, bundleId: String) -> Bool {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            return false
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: configuration, completionHandler: nil)
        return true
    }
}
