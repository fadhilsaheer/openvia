import SwiftUI

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

#Preview {
    ContentView()
}
