import Foundation

protocol CartOrderUpdater: Sendable {
    func updateOrder(nftIds: [String]) async throws
}

/// Отправляет обновлённый заказ. Сервер принимает PUT только с заголовком `Accept: application/json`,
/// которого нет в общем `NetworkClient`, поэтому запрос собирается здесь.
actor CartOrderUpdaterImpl: CartOrderUpdater {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func updateOrder(nftIds: [String]) async throws {
        let request = OrderUpdateRequest(nftIds: nftIds)
        guard let endpoint = request.endpoint else {
            throw NetworkClientError.incorrectRequest("Empty endpoint")
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = request.httpMethod.rawValue
        urlRequest.httpBody = request.rawBody
        urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue(RequestConstants.token, forHTTPHeaderField: "X-Practicum-Mobile-Token")

        let (_, response) = try await session.data(for: urlRequest)
        guard let response = response as? HTTPURLResponse else {
            throw NetworkClientError.urlSessionError
        }
        guard 200 ..< 300 ~= response.statusCode else {
            throw NetworkClientError.httpStatusCode(response.statusCode)
        }
    }
}
