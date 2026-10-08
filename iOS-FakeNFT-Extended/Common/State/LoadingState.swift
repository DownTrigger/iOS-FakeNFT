import Foundation

enum LoadingState<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(Error)
}

extension LoadingState {
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var canStartLoading: Bool {
        switch self {
        case .idle, .failed:
            true
        case .loading, .loaded:
            false
        }
    }
}
