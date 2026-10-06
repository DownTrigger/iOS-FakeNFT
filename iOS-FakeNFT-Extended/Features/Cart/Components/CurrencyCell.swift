import SwiftUI

struct CurrencyCell: View {
    let currency: Currency
    let isSelected: Bool

    private let iconSize: CGFloat = 36

    var body: some View {
        HStack(spacing: 4) {
            icon
            VStack(alignment: .leading, spacing: 0) {
                Text(currency.displayTitle)
                    .foregroundStyle(Color(.fnText))
                Text(currency.name)
                    .foregroundStyle(Color(.fnGreen))
            }
            .font(.regular13)
            .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .frame(height: 46)
        .background(Color(.fnLightGray))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.fnText), lineWidth: isSelected ? 1 : 0)
        }
    }

    private var icon: some View {
        AsyncImage(url: currency.imageURL) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder: {
            Color.clear
        }
        .padding(2)
        .frame(width: iconSize, height: iconSize)
        .background(Color(.fnBlack))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    HStack(spacing: 7) {
        CurrencyCell(currency: .preview, isSelected: true)
        CurrencyCell(currency: .preview, isSelected: false)
    }
    .padding(16)
}

extension Currency {
    static let preview = Currency(
        id: "5",
        title: "Bitcoin",
        name: "BTC",
        imageURL: URL(string: "https://code.s3.yandex.net/Mobile/iOS/Currencies/Bitcoin_(BTC).png")
    )
}
