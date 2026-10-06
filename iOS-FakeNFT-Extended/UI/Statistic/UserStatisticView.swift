//
//  UserStatisticView.swift
//  iOS-FakeNFT-Extended
//
//  Created by Irina Muravyeva on 24.09.2026.
//

import SwiftUI

struct UserStatisticView: View {
    let position: Int
    let name: String
    let avatar: String?
    let countNft: Int

    var body: some View {
        HStack(spacing: 12) {
            Text("\(position)")
                .font(.regular15)
                .tracking(-0.24)
                .foregroundStyle(.fnText)
                .frame(width: 22)

            HStack(spacing: 10) {
                if let avatar, !avatar.isEmpty, let url = URL(string: avatar) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()

                        case .empty, .failure:
                            Image(.imgAvatarPlaceholder)
                                .resizable()
                                .scaledToFill()

                        @unknown default:
                            Image(.imgAvatarPlaceholder)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())
                } else {
                    Image(.imgAvatarPlaceholder)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 28, height: 28)
                        .clipShape(Circle())
                }

                Text(name)
                    .font(.bold22)
                    .foregroundStyle(.fnText)
                    .tracking(0.35)

                Spacer()

                Text("\(countNft)")
                    .font(.bold22)
                    .foregroundStyle(.primary)
                    .frame(alignment: .trailing)
            }
            .padding(.horizontal, 14)
            .frame(height: 80)
            .background(Color(.fnLightGray))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        UserStatisticView(
            position: 1,
            name: "Alex",
            avatar: "",
            countNft: 112
        )

        UserStatisticView(
            position: 2,
            name: "Maria",
            avatar: "",
            countNft: 98
        )

        UserStatisticView(
            position: 3,
            name: "Ivan",
            avatar: "",
            countNft: 76
        )
    }
    .padding()
}
