//
//  ProfileView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct ProfileView: View {

    @State private var viewModel: ProfileViewModel
    @Environment(ServicesAssembly.self) private var services
    @Environment(Router<ProfileRoute>.self) private var router

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
                EmptyStateView(message: ProfileLocalizedText.profileLoadError.key)
            }
        }
        .navigationDestination(for: ProfileRoute.self) { route in
            switch route {
            case .myNFTs(let user):
                MyNFTsView(
                    user: user,
                    nftService: services.nftService,
                    userService: services.userService,
                    userDefaultsService: services.userDefaultsService
                )
            case .favouriteNFTs(let user):
                FavouriteNFTsView(
                    user: user,
                    nftService: services.nftService,
                    userService: services.userService
                )
            case .editProfile(let user):
                ProfileEditView(user: user, onSave: viewModel.updateUser)
            case .website(let url):
                WebViewScreen(url: url)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let user = viewModel.user {
                    Button {
                        router.push(.editProfile(user: user))
                    } label: {
                        ProfileIcon.editProfile.image
                            .frame(width: 42, height: 42)
                            .foregroundStyle(Color(.fnBlack))
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
                    Button {
                        router.push(.website(url: url))
                    } label: {
                        Text(url.absoluteString)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.blue)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                    }
                    .buttonStyle(.plain)
                }
            }
            CollectionMenu(
                nftCount: user.nftCount,
                favouritesCount: user.favouritesCount,
                onMyNFTs: {
                    router.push(.myNFTs(user: user))
                },
                onFavouriteNFTs: {
                    router.push(.favouriteNFTs(user: user))
                }
            )
            Spacer()
        }
        .padding(.top, 20)
    }
}
