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
            Text(verbatim: "\(position)")
                .font(.regular15)
                .tracking(-0.24)
                .foregroundStyle(.fnText)
                .frame(width: 22)

            HStack(spacing: 10) {
                RemoteImageView(url: avatarURL, placeholder: .avatar)
                    .frame(width: 28, height: 28)
                    .clipShape(Circle())

                Text(name)
                    .font(.bold22)
                    .foregroundStyle(.fnText)
                    .tracking(0.35)

                Spacer()

                Text(verbatim: "\(countNft)")
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

    private var avatarURL: URL? {
        guard let avatar, !avatar.isEmpty else { return nil }
        return URL(string: avatar)
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
