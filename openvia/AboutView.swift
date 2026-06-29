import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            if let appIcon = NSImage(named: NSImage.Name("AppIcon")) {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous)) // Smooth Apple-style corners

                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            } else {
                Image(systemName: "link.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.blue.gradient, .secondary)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            
            VStack(spacing: 6) {
                Text("OpenVia")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                
                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text("Route every link to the right browser.")
                .font(.headline)
                .foregroundColor(.primary.opacity(0.8))
            
            Divider()
                .frame(width: 200)
            
            VStack(spacing: 8) {
                Text("Created for macOS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack (spacing: 8) {
                    Link("Visit Website", destination: URL(string: "https://openvia.hyfic.org")!)
                        .font(.callout)
                        .foregroundColor(.blue)
                    
                    Link("View on GitHub", destination: URL(string: "https://github.com/hyfic/openvia")!)
                        .font(.callout)
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
