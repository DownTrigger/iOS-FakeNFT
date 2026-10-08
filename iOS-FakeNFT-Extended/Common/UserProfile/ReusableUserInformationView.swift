import SwiftUI

struct ReusableUserInformationView: View {
    let user: UserModel

    static let imageSize: CGFloat = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {

                RemoteImageView(url: avatarURL, placeholder: .avatar)
                    .frame(width: ReusableUserInformationView.imageSize, height: ReusableUserInformationView.imageSize)
                    .clipShape(Circle())

                Text(user.username)
                    .font(.bold22)
                    .foregroundStyle(Color(.fnText))
            }

            Text(user.bio)
                .font(.regular13)
                .foregroundStyle(Color(.fnText))
                .lineSpacing(2.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }

    private var avatarURL: URL? {
        guard let avatar = user.avatar, !avatar.isEmpty else { return nil }
        return URL(string: avatar)
    }
}
