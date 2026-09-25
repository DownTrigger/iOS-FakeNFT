//
//  ProfileEditView.swift
//  iOS-FakeNFT-Extended
//

import SwiftUI

struct ProfileEditView: View {
    let onSave: (UserModel) -> Void

    @State private var viewModel: ProfileEditViewModel
    @State private var showAvatarOptions = false
    @State private var showURLInput = false
    @State private var showExitAlert = false
    @State private var pendingAvatarURL = ""

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
                    fieldSection(title: "Имя", text: $viewModel.name, isMultiline: false)
                    fieldSection(title: "Описание", text: $viewModel.bio, isMultiline: true)
                    fieldSection(title: "Сайт", text: $viewModel.website, isMultiline: false)
                }
                .padding(.horizontal, 16)
            }

            PrimaryButton(title: .save) {
                onSave(viewModel.buildUpdatedUser())
                dismiss()
            }
            .padding(.vertical, 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if viewModel.hasChanges {
                        showExitAlert = true
                    } else {
                        dismiss()
                    }
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color(.fnText))
                }
                .contentShape(Rectangle())
            }
        }
        .confirmationDialog(
            "Фото профиля",
            isPresented: $showAvatarOptions,
            titleVisibility: .visible
        ) {
            Button("Изменить фото") {
                pendingAvatarURL = viewModel.avatarURL
                showURLInput = true
            }
            Button("Удалить фото", role: .destructive) {
                viewModel.avatarURL = ""
            }
            Button("Отмена", role: .cancel) {}
        }
        .alert("Уверены, что хотите выйти?", isPresented: $showExitAlert) {
            Button("Остаться", role: .cancel) {}
            Button("Выйти") { dismiss() }
        }
        .alert("Ссылка на фото", isPresented: $showURLInput) {
            TextField("http://www.example.com", text: $pendingAvatarURL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("Сохранить") {
                viewModel.avatarURL = pendingAvatarURL
            }
            Button("Отмена", role: .cancel) {}
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
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(.label))
                            .padding(6)
                            .background(.white, in: Circle())
                    }
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var avatarImage: some View {
        if !viewModel.avatarURL.isEmpty, let url = URL(string: viewModel.avatarURL) {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Circle().fill(Color(.fnLightGray))
            }
            .frame(width: 70, height: 70)
            .clipShape(Circle())
        } else {
            Circle()
                .fill(Color(.fnLightGray))
                .frame(width: 70, height: 70)
        }
    }

    private func fieldSection(title: String, text: Binding<String>, isMultiline: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.bold22)
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
                nftCount: 123,
                favouritesCount: 11
            ),
            onSave: { _ in }
        )
    }
}
