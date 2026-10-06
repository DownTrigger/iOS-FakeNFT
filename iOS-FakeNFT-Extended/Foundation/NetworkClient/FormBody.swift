import Foundation

struct FormBody: Sendable {
    private var pairs: [(key: String, value: String)] = []

    var data: Data {
        let encoded = pairs.map { "\(Self.encode($0.key))=\(Self.encode($0.value))" }
        return Data(encoded.joined(separator: "&").utf8)
    }

    mutating func add(_ key: String, _ value: String) {
        pairs.append((key, value))
    }

    mutating func add(_ key: String, _ values: [String], whenEmpty emptyValue: String? = nil) {
        guard !values.isEmpty else {
            if let emptyValue {
                add(key, emptyValue)
            }
            return
        }
        values.forEach { add(key, $0) }
    }

    private static let unreserved = CharacterSet(
        charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
    )

    private static func encode(_ string: String) -> String {
        string.addingPercentEncoding(withAllowedCharacters: unreserved) ?? ""
    }
}
