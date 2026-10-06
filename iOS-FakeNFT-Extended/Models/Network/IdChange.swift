import Foundation

enum IdChange: Sendable, Equatable {
    case add(String)
    case remove(String)

    func apply(to ids: [String]) -> [String] {
        switch self {
        case .add(let id):
            return ids.contains(id) ? ids : ids + [id]
        case .remove(let id):
            return ids.filter { $0 != id }
        }
    }
}
