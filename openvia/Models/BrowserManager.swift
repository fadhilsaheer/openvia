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
        var browsers: [Browser] = []
        let workspace = NSWorkspace.shared
        
        guard let httpURL = URL(string: "http://example.com") else { return }
        
        // Query Launch Services for all apps that can handle HTTP URLs
        let browserURLs = workspace.urlsForApplications(toOpen: httpURL)
        
        for url in browserURLs {
            if let bundleId = Bundle(url: url)?.bundleIdentifier {
                let bundle = Bundle(url: url)
                let name = (bundle?.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String) ??
                           (bundle?.object(forInfoDictionaryKey: "CFBundleName") as? String) ??
                           url.deletingPathExtension().lastPathComponent
                let icon = workspace.icon(forFile: url.path).resized(to: NSSize(width: 16, height: 16))
                
                if !browsers.contains(where: { $0.bundleId == bundleId }) {
                    browsers.append(Browser(name: name, bundleId: bundleId, icon: icon, url: url))
                }
            }
        }
        
        // Exclude our own app from the list just in case we get picked up
        let ourBundleId = Bundle.main.bundleIdentifier ?? "hyfic.org.openvia"
        browsers.removeAll(where: { $0.bundleId == ourBundleId })
        
        // Also get the current system default browser
        if let defaultURL = workspace.urlForApplication(toOpen: httpURL) {
            if let bundleId = Bundle(url: defaultURL)?.bundleIdentifier, bundleId != ourBundleId {
                self.defaultBrowser = browsers.first(where: { $0.bundleId == bundleId })
            }
        }
        
        // Sort alphabetically
        self.installedBrowsers = browsers.sorted(by: { $0.name < $1.name })
    }
}

extension NSImage {
    func resized(to newSize: NSSize) -> NSImage {
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: newSize), from: NSRect(origin: .zero, size: self.size), operation: .sourceOver, fraction: 1.0)
        newImage.unlockFocus()
        return newImage
    }
}
