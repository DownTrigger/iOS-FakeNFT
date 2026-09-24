import SwiftUI

@MainActor
@Observable
final class Router<Route: Hashable> {
    var path: [Route] = []

    func push(_ route: Route) {
        guard path.last != route else { return }
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}

private enum PreviewRoute: Hashable {
    case detail(Int)
}

private struct PreviewRootView: View {
    @State private var router = Router<PreviewRoute>()

    var body: some View {
        NavigationStack(path: $router.path) {
            Button {
                router.push(.detail(1))
            } label: {
                Text(verbatim: "Item 1")
            }
            .navigationDestination(for: PreviewRoute.self) { route in
                switch route {
                case .detail(let number):
                    PreviewDetailView(number: number)
                }
            }
        }
        .environment(router)
    }
}

private struct PreviewDetailView: View {
    @Environment(Router<PreviewRoute>.self) private var router
    let number: Int

    var body: some View {
        VStack(spacing: 16) {
            Button {
                router.push(.detail(number + 1))
            } label: {
                Text(verbatim: "Next")
            }
            Button {
                router.popToRoot()
            } label: {
                Text(verbatim: "Back to root")
            }
        }
        .navigationTitle(Text(verbatim: "Item \(number)"))
    }
}

#Preview {
    PreviewRootView()
}
