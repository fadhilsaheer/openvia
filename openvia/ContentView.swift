import SwiftUI

struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .sidebar
        
        DispatchQueue.main.async {
            view.window?.isOpaque = false
            view.window?.backgroundColor = .clear
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

struct ContentView: View {
    var body: some View {
        TabView {
            RulesView()
                .tabItem {
                    Label("Rules", systemImage: "list.bullet")
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(minWidth: 520, minHeight: 450)
        .background(VisualEffectBackground().ignoresSafeArea())
    }
}

struct RulesView: View {
    @StateObject private var router = Router.shared
    @StateObject private var browserManager = BrowserManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: Text("Routing Rules").font(.headline).foregroundColor(.secondary)) {
                    ForEach($router.rules) { $rule in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Picker("", selection: $rule.scheme) {
                                    ForEach(Rule.URLSchemeMatch.allCases, id: \.self) { scheme in
                                        Text(scheme.rawValue).tag(scheme)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 110)
                                
                                Picker("", selection: $rule.patternType) {
                                    ForEach(Rule.PatternType.allCases, id: \.self) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 140)
                                
                                Spacer()
                                
                                Button(action: {
                                    if let index = router.rules.firstIndex(where: { $0.id == rule.id }) {
                                        withAnimation {
                                            router.rules.remove(at: index)
                                        }
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .frame(width: 14, height: 14)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            HStack {
                                TextField("Pattern (e.g. *.company.com)", text: $rule.pattern)
                                    .textFieldStyle(.roundedBorder)
                                
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.secondary)
                                    
                                Picker("", selection: $rule.browserId) {
                                    ForEach(browserManager.installedBrowsers) { browser in
                                        HStack(alignment: .center) {
                                            if let icon = browser.icon {
                                                Image(nsImage: icon)
                                            }
                                            Text(browser.name)
                                        }
                                        .tag(browser.bundleId)
                                    }
                                }
                                .labelsHidden()
                                .frame(width: 150, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                        .background(.regularMaterial)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .onMove { source, destination in
                        router.rules.move(fromOffsets: source, toOffset: destination)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    
                    Button(action: {
                        withAnimation {
                            let defaultId = browserManager.defaultBrowser?.bundleId ?? "com.apple.Safari"
                            let newRule = Rule(pattern: "", browserId: defaultId)
                            router.rules.append(newRule)
                        }
                    }) {
                        Label("Add Rule", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.clear)
                }
                
                Section(header: Text("Fallback Behavior").font(.headline).foregroundColor(.secondary)) {
                    HStack {
                        Text("When no rule matches:")
                        Spacer()
                        Picker("", selection: $router.fallback) {
                            Text("System Default").tag("")
                            ForEach(browserManager.installedBrowsers) { browser in
                                HStack {
                                    if let icon = browser.icon {
                                        Image(nsImage: icon)
                                    }
                                    Text(browser.name)
                                }.tag(browser.bundleId)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 180)
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                    .background(.regularMaterial)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .scrollContentBackground(.hidden)
            
            Divider()
            
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                Spacer()
                Button("Set as Default Browser") {
                    let url = URL(string: "x-apple.systempreferences:com.apple.preference.general")!
                    NSWorkspace.shared.open(url)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            if let appIcon = NSImage(named: NSImage.Name("AppIcon")) {
                Image(nsImage: appIcon)
                    .resizable()
                    .frame(width: 80, height: 80)
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
                
                Link("View on GitHub", destination: URL(string: "https://github.com/hyfic/openvia")!)
                    .font(.callout)
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
