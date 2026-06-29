import Cocoa
import SwiftUI
import Combine

struct Browser: Identifiable, Hashable {
    var id: String { bundleId }
    let name: String
    let bundleId: String
    let icon: NSImage?
    let url: URL
}

class BrowserManager: ObservableObject {
    static let shared = BrowserManager()
    
    @Published var installedBrowsers: [Browser] = []
    @Published var defaultBrowser: Browser?
    
    init() {
        refreshBrowsers()
    }
    
    func refreshBrowsers() {
        // List of known browser bundle IDs to look for
        let knownBrowserIds = [
            "com.apple.Safari",
            "com.google.Chrome",
            "org.mozilla.firefox",
            "company.thebrowser.Browser", // Arc
            "com.microsoft.edgemac",
            "com.brave.Browser",
            "com.kagi.kagimacOS", // Orion
            "com.operasoftware.Opera",
            "com.vivaldi.Vivaldi"
        ]
        
        var browsers: [Browser] = []
        let workspace = NSWorkspace.shared
        
        for bundleId in knownBrowserIds {
            if let url = workspace.urlForApplication(withBundleIdentifier: bundleId) {
                let bundle = Bundle(url: url)
                let name = (bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ??
                           (bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String) ??
                           url.deletingPathExtension().lastPathComponent
                let icon = workspace.icon(forFile: url.path)
                browsers.append(Browser(name: name, bundleId: bundleId, icon: icon, url: url))
            }
        }
        
        // Exclude our own app from the list just in case we get picked up
        let ourBundleId = Bundle.main.bundleIdentifier ?? "hyfic.org.openvia"
        browsers.removeAll(where: { $0.bundleId == ourBundleId })
        
        // Also get the current system default browser for http
        if let defaultURL = workspace.urlForApplication(toOpen: URL(string: "http://example.com")!) {
            if let bundleId = Bundle(url: defaultURL)?.bundleIdentifier, bundleId != ourBundleId {
                if !browsers.contains(where: { $0.bundleId == bundleId }) {
                    let bundle = Bundle(url: defaultURL)
                    let name = (bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ??
                               (bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String) ??
                               defaultURL.deletingPathExtension().lastPathComponent
                    let icon = workspace.icon(forFile: defaultURL.path)
                    let defaultB = Browser(name: name, bundleId: bundleId, icon: icon, url: defaultURL)
                    browsers.append(defaultB)
                    self.defaultBrowser = defaultB
                } else {
                    self.defaultBrowser = browsers.first(where: { $0.bundleId == bundleId })
                }
            }
        }
        
        // Sort alphabetically
        self.installedBrowsers = browsers.sorted(by: { $0.name < $1.name })
    }
}
