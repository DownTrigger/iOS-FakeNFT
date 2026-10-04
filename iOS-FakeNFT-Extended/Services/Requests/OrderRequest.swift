import Foundation

struct OrderRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }
}

struct OrderUpdateRequest: NetworkRequest {
    var httpMethod: HttpMethod { .put }

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/1")
    }

    let rawBody: Data?

    init(nftIds: [String]) {
        let params = nftIds.map { id in
            "nfts=\(id.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? id)"
        }
        rawBody = params.joined(separator: "&").data(using: .utf8)
    }
}
