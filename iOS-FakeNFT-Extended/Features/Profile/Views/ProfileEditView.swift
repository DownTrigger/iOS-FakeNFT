import SwiftUI

struct ProfileEditView: View {
    let onSave: (UserModel) -> Void

    @State private var viewModel: ProfileEditViewModel
    @State private var showAvatarOptions = false
    @State private var showURLInput = false
    @State private var showExitAlert = false
    @State private var pendingAvatarURLString = ""

    @Environment(\.dismiss) private var dismiss

    init(user: UserModel, onSave: @escaping (UserModel) -> Void) {
        self.onSave = onSave
        _viewModel = State(initialValue: ProfileEditViewModel(user: user))
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    avatarSection
                    fieldSection(title: ProfileLocalizedText.editName.key, text: $viewModel.name, isMultiline: false)
                    fieldSection(
                        title: ProfileLocalizedText.editDescription.key,
                        text: $viewModel.bio,
                        isMultiline: true
                    )
                    fieldSection(
                        title: ProfileLocalizedText.editWebsite.key,
                        text: $viewModel.website,
                        isMultiline: false
                    )
                }
                .padding(.horizontal, 16)
            }

            PrimaryButton(title: .save) {
                onSave(viewModel.buildUpdatedUser())
                dismiss()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color(.fnBackground))
        .toolbar(.hidden, for: .tabBar)
        .backButton {
            if viewModel.hasChanges {
                showExitAlert = true
            } else {
                dismiss()
            }
        }
        .confirmationDialog(
            ScreenLocalizedText.profilePhoto.key,
            isPresented: $showAvatarOptions,
            titleVisibility: .visible
        ) {
            Button(ProfileLocalizedText.changePhoto.key) {
                pendingAvatarURLString = viewModel.avatarURL
                showURLInput = true
            }
            Button(ProfileLocalizedText.deletePhoto.key, role: .destructive) {
                viewModel.avatarURL = ""
            }
            Button(role: .cancel) {} label: { Text(AlertLocalizedText.cancel.resource) }
        }
        .alert(ProfileLocalizedText.exitConfirmation.key, isPresented: $showExitAlert) {
            Button(ProfileLocalizedText.stay.key, role: .cancel) {}
            Button(ProfileLocalizedText.exit.key) { dismiss() }
        }
        .alert(ProfileLocalizedText.photoLink.key, isPresented: $showURLInput) {
            TextField(text: $pendingAvatarURLString, prompt: Text(verbatim: "http://www.example.com")) { EmptyView() }
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button(PrimaryButtonLocalizedText.save.key) {
                viewModel.avatarURL = pendingAvatarURLString
            }
            Button(role: .cancel) {} label: { Text(AlertLocalizedText.cancel.resource) }
        }
    }

    private var avatarSection: some View {
        HStack {
            Spacer()
            Button {
                showAvatarOptions = true
            } label: {
                avatarImage
                    .overlay(alignment: .bottomTrailing) {
                        ProfileIcon.camera.image
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(.fnText))
                            .padding(6)
                            .background(Color(.fnLightGray), in: Circle())
                    }
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.top, -8)
    }

    @ViewBuilder
    private var avatarImage: some View {
        RemoteImageView(url: viewModel.avatarImageURL, placeholder: .avatar)
            .frame(width: 70, height: 70)
            .clipShape(Circle())
    }

    private func fieldSection(title: LocalizedStringKey, text: Binding<String>, isMultiline: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.bold22)
                .foregroundStyle(Color(.fnText))
                .frame(height: 28)
            AppTextField(placeholder: title, text: text, isMultiline: isMultiline)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileEditView(
            user: UserModel(
                avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQIMUe7M2kZo-Yb2FPmD6bbleK3Ri3tQNR0Gtp8aFiQ2UAF5VHukRALrltv&s=10",
                username: "Joaquin Phoenix",
                bio: "Дизайнер из Казани, люблю цифровое искусство и бейглы. В моей коллекции уже 100+ NFT.",
                userWebSite: "https://example.com",
                nfts: [],
                likes: []
            ),
            onSave: { _ in }
        )
    }
}
