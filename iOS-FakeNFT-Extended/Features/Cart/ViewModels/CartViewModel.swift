import Foundation

@MainActor
@Observable
final class CartViewModel {
    private(set) var state: LoadingState<[Nft]> = .idle
    private(set) var sortOption: CartSortOption = .byTitle
    private(set) var nftToDelete: Nft?
    private(set) var isDeleting = false
    var alert: AlertModel?

    var items: [Nft] {
        guard case let .loaded(items) = state else {
            return []
        }
        switch sortOption {
        case .byTitle, .byName:
            return sortBy(items, keyPath: \.name)
        case .byRating:
            return sortBy(items, keyPath: \.rating, ascending: false)
        case .byPrice:
            return sortBy(items, keyPath: \.price, ascending: false)
        }
    }

    var totalPrice: Double {
        items.reduce(0) { $0 + $1.price }
    }

    func applySort(_ option: CartSortOption) {
        sortOption = option
    }

    func requestDelete(_ nft: Nft) {
        guard nftToDelete == nil, !isDeleting else {
            return
        }
        nftToDelete = nft
    }

    func cancelDelete() {
        nftToDelete = nil
    }

    func confirmDelete(using service: CartService) async {
        guard let nft = nftToDelete, case let .loaded(items) = state, !isDeleting else {
            return
        }
        isDeleting = true
        defer { isDeleting = false }

        let remaining = items.filter { $0.id != nft.id }
        do {
            try await service.updateOrder(nftIds: remaining.map(\.id))
            state = .loaded(remaining)
            nftToDelete = nil
        } catch {
            nftToDelete = nil
            alert = .retryError(title: CartLocalizedText.deleteError.text) { [weak self] in
                Task {
                    self?.requestDelete(nft)
                    await self?.confirmDelete(using: service)
                }
            }
        }
    }

    func load(using service: CartService) async {
        state = .loading
        await fetch(using: service)
    }

    func refresh(using service: CartService) async {
        await fetch(using: service)
    }

    // MARK: - Private

    private func fetch(using service: CartService) async {
        do {
            let items = try await service.loadCart()
            state = .loaded(items)
        } catch is CancellationError {
            resetLoadingState()
        } catch let error as URLError where error.code == .cancelled {
            resetLoadingState()
        } catch {
            if case .loading = state {
                state = .failed(error)
            }
            alert = .retryError(title: CartLocalizedText.loadError.text) { [weak self] in
                Task { await self?.load(using: service) }
            }
        }
    }

    private func resetLoadingState() {
        if case .loading = state {
            state = .idle
        }
    }
}
