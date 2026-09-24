import Foundation

enum PriceFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func string(from price: Double) -> String {
        let number = formatter.string(from: NSNumber(value: price)) ?? String(price)
        return "\(number) ETH"
    }
}
