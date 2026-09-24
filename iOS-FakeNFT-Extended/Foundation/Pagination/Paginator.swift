import SwiftUI

@MainActor
@Observable
final class Paginator<Item: Identifiable> {
    private(set) var items: [Item] = []
    private(set) var isLoading = false
    private(set) var hasMorePages = true

    private let pageSize: Int
    private let loadPage: (_ page: Int, _ size: Int) async throws -> [Item]
    private var nextPage = 0
    private var generation = 0

    init(pageSize: Int, loadPage: @escaping (_ page: Int, _ size: Int) async throws -> [Item]) {
        self.pageSize = pageSize
        self.loadPage = loadPage
    }

    func loadNextPage() async throws {
        guard !isLoading, hasMorePages else { return }
        isLoading = true
        let currentGeneration = generation

        do {
            let page = try await loadPage(nextPage, pageSize)
            guard currentGeneration == generation else { return }
            items.append(contentsOf: page)
            nextPage += 1
            hasMorePages = page.count == pageSize
            isLoading = false
        } catch {
            if currentGeneration == generation {
                isLoading = false
            }
            throw error
        }
    }

    func loadNextPageIfNeeded(currentItem: Item) async throws {
        guard currentItem.id == items.last?.id else { return }
        try await loadNextPage()
    }

    func reset() {
        generation += 1
        items = []
        nextPage = 0
        hasMorePages = true
        isLoading = false
    }
}

private struct PreviewItem: Identifiable {
    let id: Int
}

private struct PaginatorPreview: View {
    @State private var paginator = Paginator<PreviewItem>(pageSize: 15) { page, size in
        try await Task.sleep(for: .seconds(1))
        let start = page * size
        let end = min(start + size, 100)
        return (start..<end).map { PreviewItem(id: $0) }
    }

    var body: some View {
        List {
            ForEach(paginator.items) { item in
                Text(verbatim: "Item \(item.id)")
                    .task { try? await paginator.loadNextPageIfNeeded(currentItem: item) }
            }
            if paginator.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .id(paginator.items.count)
            }
        }
        .task { try? await paginator.loadNextPage() }
    }
}

#Preview {
    PaginatorPreview()
}
