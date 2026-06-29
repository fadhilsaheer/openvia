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
                        HStack {
                            TextField("Pattern (e.g. *.company.com)", text: $rule.pattern)
                                .textFieldStyle(.roundedBorder)
                            
                            Picker("", selection: $rule.browserId) {
                                ForEach(browserManager.installedBrowsers) { browser in
                                    Text(browser.name).tag(browser.bundleId)
                                }
                            }
                            .frame(width: 150)
                            
                            Button(action: {
                                if let index = router.rules.firstIndex(where: { $0.id == rule.id }) {
                                    router.rules.remove(at: index)
                                }
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
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
                            Text(browser.name).tag(browser.bundleId)
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
