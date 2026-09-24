import SwiftUI

struct ProfileView: View {
    var body: some View {
        Text(TabLocalizedText.profile.key)
            .font(.bold17)
            .foregroundStyle(Color(.fnText))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.fnBackground))
    }
}
