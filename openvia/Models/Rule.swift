import Foundation

struct Rule: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    var pattern: String
    var browserId: String // Bundle identifier of the target browser
    
    // Checks if a given host matches the pattern
    func matches(host: String) -> Bool {
        if pattern == "*" { return true }
        
        let lowerHost = host.lowercased()
        let lowerPattern = pattern.lowercased()
        
        if lowerPattern.starts(with: "*.") {
            let suffix = lowerPattern.dropFirst(2)
            return lowerHost == suffix || lowerHost.hasSuffix(".\(suffix)")
        }
        
        return lowerHost == lowerPattern
    }
}
