//
//  ProfileView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct ProfileView: View {
    
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        VStack(spacing: 40) {
            VStack(alignment: .leading, spacing: 8) {
                ReusableUserInformationView(user: viewModel.user)
                if let website = viewModel.user.userWebSite, !website.isEmpty, let url = URL(string: website) {
                    NavigationLink {
                        WebViewScreen(url: url)
                    } label: {
                        Text(website)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.blue)
                            .padding(.horizontal, 16)
                    }
                }
            }
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
