//
//  ProfileView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct ProfileView: View {
    
    @State private var viewModel = ProfileViewModel()

    var body: some View {
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ProfileEditView(user: viewModel.user, onSave: viewModel.updateUser)
                } label: {
                    Image(.icEdit)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
