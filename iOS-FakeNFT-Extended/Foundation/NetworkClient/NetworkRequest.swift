import Foundation

enum HttpMethod: String {
    case get = "GET"
    case put = "PUT"
}

protocol NetworkRequest: Sendable {
    var endpoint: URL? { get }
    var httpMethod: HttpMethod { get }
    var rawBody: Data? { get }
}

extension NetworkRequest {
    var httpMethod: HttpMethod { .get }
    var rawBody: Data? { nil }
}
