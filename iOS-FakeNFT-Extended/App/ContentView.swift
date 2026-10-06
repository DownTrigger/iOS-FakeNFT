import SwiftUI

struct ContentView: View {
    @Environment(ServicesAssembly.self) private var services

    var body: some View {
        TabBarView()
            .task {
                await services.loadCurrentUserLikes()
            }
    }
}
