import Foundation

struct UserOrderRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}

struct UserOrderUpdateRequest: NetworkRequest {
    var httpMethod: HttpMethod { .put }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    let rawBody: Data?

    init(nfts: [String]) {
        var body = FormBody()
        body.add("nfts", nfts)
        rawBody = body.data
    }
}
