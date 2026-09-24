//
//  CollectionMenu.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct CollectionMenu: View {
    
    let viewModel: UserInformationViewViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            CollectionMenuRow(
                action: viewModel.openMyNFTs,
                title: "Мои NFT",
                count: viewModel.user.nftCount
            )
            CollectionMenuRow(
                action: viewModel.openFavouriteNFTs,
                title: "Избранные NFT",
                count: viewModel.user.favouritesCount
            )
        }
    }
}

struct CollectionMenuRow: View {
    let action: () -> Void
    let title: String
    let count: Int
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                Text("(\(count))")
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
            .font(.system(size: 17, weight: .bold))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 54)
    }
}

#Preview("Main") {
    let vm = UserInformationViewViewModel()
    vm.user = UserModel(avatar: nil, username: "Preview", bio: "", userWebSite: nil, nftCount: 5, favouritesCount: 3)
    return CollectionMenu(viewModel: vm)
}

#Preview("Row") {
    CollectionMenuRow(action: {}, title: "My NFTs", count: 112)
}
