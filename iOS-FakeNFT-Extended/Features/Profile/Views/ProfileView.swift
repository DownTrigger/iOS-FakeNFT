//
//  ProfileView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct ProfileView: View {

    @State private var viewModel: ProfileViewModel
    @Environment(ServicesAssembly.self) private var services
    @Environment(Router<ProfileRoute>.self) private var router

    private let profileService: UserProfileService
    private let userState: UserState

    init(profileService: UserProfileService, userState: UserState) {
        self.profileService = profileService
        self.userState = userState
        _viewModel = State(initialValue: ProfileViewModel(profileService: profileService, userState: userState))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                AppLoadingView()
            case .loaded(let user):
                profileContent(user: user)
            case .failed:
                if viewModel.alert == nil {
                    ErrorStateView(message: ProfileLocalizedText.profileLoadError.key) {
                        Task { await viewModel.loadUser() }
                    }
                }
            }
        }
        .navigationDestination(for: ProfileRoute.self) { route in
            switch route {
            case .myNFTs(let user):
                MyNFTsView(
                    user: user,
                    nftService: services.nftService,
                    userState: userState,
                    userDefaultsService: services.userDefaultsService
                )
            case .favouriteNFTs:
                FavouriteNFTsView(
                    nftService: services.nftService,
                    profileService: profileService,
                    userState: userState
                )
            case .editProfile(let user):
                ProfileEditView(user: user, onSave: { updated in
                    Task { await viewModel.save(updated) }
                })
            case .website(let url):
                WebViewScreen(url: url)
            }
        }
        .appAlert(item: $viewModel.alert)
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
            ToolbarItem(placement: .topBarTrailing) {
                if let user = viewModel.user {
                    Button {
                        router.push(.editProfile(user: user))
                    } label: {
                        ProfileIcon.editProfile.image
                            .frame(width: 42, height: 42)
                            .foregroundStyle(Color(.fnText))
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
                            .font(.regular15)
                            .foregroundStyle(Color(.fnBlue))
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
                favouritesCount: viewModel.favouritesCount,
                onMyNFTs: {
                    router.push(.myNFTs(user: user))
                },
                onFavouriteNFTs: {
                    router.push(.favouriteNFTs)
                }
            )
            Spacer()
        }
        .padding(.top, 20)
    }
}
