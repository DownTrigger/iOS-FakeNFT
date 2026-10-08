import SwiftUI

struct ErrorStateView: View {
    let message: LocalizedStringKey
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.bold17)
                .foregroundStyle(Color(.fnText))
                .multilineTextAlignment(.center)
            Button(action: onRetry) {
                Text(AlertLocalizedText.retry.resource)
                    .font(.bold17)
                    .foregroundStyle(Color(.fnBackground))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color(.fnText))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ErrorStateView(message: CatalogLocalizedText.loadError.key) {}
}
