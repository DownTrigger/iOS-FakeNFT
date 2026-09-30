//
//  ProfileView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct ProfileView: View {

    @State private var viewModel: ProfileViewModel
    @Environment(ServicesAssembly.self) private var services

    init(userService: UserService) {
        _viewModel = State(initialValue: ProfileViewModel(userService: userService))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                AppLoadingView()
            case .loaded(let user):
                profileContent(user: user)
            case .failed:
                EmptyStateView(message: "Не удалось загрузить профиль")
            }
        }
        .task {
            await viewModel.loadUser()
        }
        .background(Color(.fnBackground))
        .overlay {
            if viewModel.isUpdating {
                AppLoadingView()
                    .background(Color(.fnBackground).opacity(0.5))
            }
        }
        .navigationDestination(isPresented: $viewModel.showMyNFTs) {
            if let user = viewModel.user {
                MyNFTsView(
                    nftIds: user.nfts,
                    likedIds: user.likes,
                    username: user.username,
                    nftService: services.nftService
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let user = viewModel.user {
                    NavigationLink {
                        ProfileEditView(user: user, onSave: viewModel.updateUser)
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .frame(width: 42, height: 42)
                            .foregroundStyle(Color(.label))
                    }
                }
            }
        }
    }

    private func profileContent(user: UserModel) -> some View {
        VStack(spacing: 40) {
            VStack(alignment: .leading, spacing: 8) {
                ReusableUserInformationView(user: user)
                if let url = viewModel.websiteURL {
                    NavigationLink {
                        WebViewScreen(url: url)
                    } label: {
                        Text(url.absoluteString)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.blue)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                    }
                }
            }
            CollectionMenu(
                nftCount: user.nftCount,
                favouritesCount: user.favouritesCount,
                onMyNFTs: viewModel.openMyNFTs,
                onFavouriteNFTs: viewModel.openFavouriteNFTs
            )
            Spacer()
        }
        .padding(.top, 20)
    }
}
