import Foundation

protocol UserDefaultsService: Sendable {
    func string(forKey key: String) -> String?
    func set(_ value: String, forKey key: String)
}

final class UserDefaultsServiceImpl: UserDefaultsService {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func string(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    func set(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}
