import Foundation

enum RequestConstants {
    static let baseURL = "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net"
    static let token: String = {
        Bundle.main.object(forInfoDictionaryKey: "APIToken") as? String ?? ""
    }()
}
