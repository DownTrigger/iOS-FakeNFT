//
//  ReusableUserInformationView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct ReusableUserInformationView: View {
    let user: UserModel

    static let imageSize: CGFloat = 70

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {

                Group {
                    if let avatar = user.avatar, !avatar.isEmpty, let url = URL(string: avatar) {
                        AsyncImage(url: url) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Image(.imgAvatarPlaceholder).resizable().scaledToFill()
                        }
                    } else {
                        Image(.imgAvatarPlaceholder).resizable().scaledToFill()
                    }
                }
                .frame(width: ReusableUserInformationView.imageSize, height: ReusableUserInformationView.imageSize)
                .clipShape(Circle())

                Text(user.username)
                    .font(.system(size: 22, weight: .bold))
            }

            Text(user.bio)
                .font(.system(size: 13, weight: .regular))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}

