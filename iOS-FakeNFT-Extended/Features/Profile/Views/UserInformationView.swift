//
//  UserInformationView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct UserInformationView: View {
    let user: UserModel

    static let imageSize: CGFloat = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {

                if let avatar = user.avatar, !avatar.isEmpty, let url = URL(string: avatar) {
                    AsyncImage(url: url)
                        .frame(width: UserInformationView.imageSize, height: UserInformationView.imageSize)
                        .clipShape(Circle())
                }

                Text(user.username)
                    .font(.system(size: 22, weight: .bold))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(user.bio)
                    .font(.system(size: 13, weight: .regular))

                if let website = user.userWebSite, !website.isEmpty, let url = URL(string: website) {
                    Link(website, destination: url)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}

#Preview {
    UserInformationView(user: UserModel(
        avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQIMUe7M2kZo-Yb2FPmD6bbleK3Ri3tQNR0Gtp8aFiQ2UAF5VHukRALrltv&s=10",
        username: "Joaquin Phoenix",
        bio: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT.",
        userWebSite: "https://example.com",
        nftCount: 12,
        favouritesCount: 5
    ))
}
