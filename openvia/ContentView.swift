import SwiftUI

struct ContentView: View {
    @StateObject private var router = Router.shared
    @StateObject private var browserManager = BrowserManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("OpenVia Rules")
                    .font(.headline)
                Spacer()
            }
            .padding()
            
            List {
                Section(header: Text("Rules (Evaluated top to bottom)")) {
                    ForEach($router.rules) { $rule in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Picker("", selection: $rule.scheme) {
                                    ForEach(Rule.URLSchemeMatch.allCases, id: \.self) { scheme in
                                        Text(scheme.rawValue).tag(scheme)
                                    }
                                }
                                .frame(width: 110)
                                
                                Picker("", selection: $rule.patternType) {
                                    ForEach(Rule.PatternType.allCases, id: \.self) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .frame(width: 140)
                                
                                Spacer()
                                
                                Button(action: {
                                    if let index = router.rules.firstIndex(where: { $0.id == rule.id }) {
                                        router.rules.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .scaledToFit()
                                        .frame(width: 10, height: 10)
                                    
                                }
                                .buttonStyle(.plain)
                            }
                            
                            HStack {
                                TextField("Pattern", text: $rule.pattern)
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
                        .padding(.vertical, 4)
                    }
                    .onMove { source, destination in
                        router.rules.move(fromOffsets: source, toOffset: destination)
                    }
                    
                    Button(action: {
                        let defaultId = browserManager.defaultBrowser?.bundleId ?? "com.apple.Safari"
                        let newRule = Rule(pattern: "", browserId: defaultId)
                        router.rules.append(newRule)
                    }) {
                        Label("Add Rule", systemImage: "plus")
                    }
                }
                
                Section(header: Text("Fallback Browser")) {
                    Picker("When no rule matches", selection: $router.fallback) {
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
                }
            }
            
            HStack {
                Button("Quit OpenVia") {
                    NSApplication.shared.terminate(nil)
                }
                Spacer()
                Button("Set as Default Browser") {
                    let url = URL(string: "x-apple.systempreferences:com.apple.preference.general")!
                    NSWorkspace.shared.open(url)
                }
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 400)
    }
}

#Preview {
    ContentView()
}
