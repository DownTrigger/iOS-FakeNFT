//
//  ProfileView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct ProfileView: View {
    
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        HStack {
            Spacer()

            Button {
                viewModel.openEditProfile()
            } label: {
                Image(.icEdit)
                    .frame(width: 42, height: 42)
            }
        }
        .padding(.trailing, 9)
        
        VStack(spacing: 40) {
            UserInformationView(user: viewModel.user)
            CollectionMenu(
                nftCount: viewModel.user.nftCount,
                favouritesCount: viewModel.user.favouritesCount,
                onMyNFTs: viewModel.openMyNFTs,
                onFavouriteNFTs: viewModel.openFavouriteNFTs
            )
            
            Spacer()
        }
        .padding(.top, 20)
    }
}

#Preview {
    ProfileView()
}
