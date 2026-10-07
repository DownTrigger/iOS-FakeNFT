import SwiftUI

struct PrimaryButton: View {
    let title: PrimaryButtonLocalizedText
    let action: () -> Void
    var isDisabled: Bool = false
    var body: some View {
        Button(action: action) {
            Text(title.key)
                .font(.bold17)
                .foregroundStyle(Color(.fnBackground))
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color(.fnText))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isDisabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: .pay) {}
        PrimaryButton(title: .save) {}
        PrimaryButton(title: .pay, action: {}, isDisabled: true)
    }
    .padding(.horizontal, 16)
}

#Preview("Dark Mode") {
    PrimaryButton(
        title: .pay,
        action: {}
    )
    .padding(.horizontal, 16)
    .preferredColorScheme(.dark)
}
