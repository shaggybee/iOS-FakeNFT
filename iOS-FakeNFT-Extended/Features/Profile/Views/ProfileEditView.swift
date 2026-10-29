import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProfileEditViewModel
    @State private var showsPhotoActions = false
    @State private var showsPhotoURL = false
    @State private var photoURL = ""
    @State private var showsDiscardConfirmation = false
    let onSaved: (UserProfile) -> Void

    init(profile: UserProfile, service: any ProfileService, onSaved: @escaping (UserProfile) -> Void) {
        _viewModel = State(initialValue: ProfileEditViewModel(profile: profile, service: service))
        self.onSaved = onSaved
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    photoButton
                        .frame(maxWidth: .infinity)

                    field("Имя") {
                        TextField("Имя", text: $viewModel.draft.name)
                            .textContentType(.name)
                            .accessibilityIdentifier("profile.edit.name")
                    }

                    field("Описание") {
                        TextField("Описание", text: $viewModel.draft.description, axis: .vertical)
                            .lineLimit(5...8)
                            .accessibilityIdentifier("profile.edit.description")
                    }

                    field("Сайт") {
                        TextField("https://example.com", text: $viewModel.draft.website)
                            .keyboardType(.URL)
                            .textContentType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .accessibilityIdentifier("profile.edit.website")
                    }

                    if let message = viewModel.validationMessage {
                        Text(message)
                            .font(AppFont.regular13)
                            .foregroundStyle(.redUniversal)
                            .accessibilityIdentifier("profile.edit.validation")
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(.whitePrimary)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        if viewModel.hasChanges { showsDiscardConfirmation = true }
                        else { dismiss() }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .accessibilityLabel("Назад")
                    .accessibilityIdentifier("profile.edit.back")
                }
            }
            .safeAreaInset(edge: .bottom) {
                BaseButton(title: "Сохранить") { save() }
                    .disabled(!viewModel.canSave)
                    .opacity(viewModel.canSave ? 1 : 0.5)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.whitePrimary)
                    .accessibilityIdentifier("profile.edit.save")
            }
            .disabled(viewModel.isSaving)
            .overlay {
                if viewModel.isSaving { BlockingProgressView() }
            }
            .interactiveDismissDisabled(viewModel.hasChanges || viewModel.isSaving)
            .confirmationDialog("Изменить фото профиля", isPresented: $showsPhotoActions, titleVisibility: .visible) {
                Button("Изменить фото") {
                    photoURL = viewModel.draft.avatar
                    showsPhotoURL = true
                }
                Button("Удалить фото", role: .destructive) { viewModel.draft.avatar = "" }
                Button("Отмена", role: .cancel) { }
            }
            .alert("Ссылка на фото", isPresented: $showsPhotoURL) {
                TextField("https://example.com/photo.jpg", text: $photoURL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Button("Сохранить") { viewModel.draft.avatar = photoURL }
                Button("Отмена", role: .cancel) { }
            }
            .alert("Выйти без сохранения?", isPresented: $showsDiscardConfirmation) {
                Button("Выйти", role: .destructive) { dismiss() }
                Button("Остаться", role: .cancel) { }
            } message: {
                Text("Изменения профиля будут потеряны.")
            }
            .alert("Не удалось сохранить профиль", isPresented: $viewModel.showsError) {
                Button("Повторить") { save() }
                Button("Отмена", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .tint(.blackPrimary)
        }
    }

    private var photoButton: some View {
        Button { showsPhotoActions = true } label: {
            ProfileAvatarView(url: ProfileURL.webURL(from: viewModel.draft.avatar), size: 70)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "camera.circle.fill")
                        .font(.system(size: 24))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.whitePrimary, .blackPrimary)
                }
        }
        .accessibilityLabel("Изменить фото профиля")
    }

    private func field<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(AppFont.bold22)
            content()
                .font(AppFont.regular17)
                .padding(12)
                .background(.lightGrey)
                .clipShape(.rect(cornerRadius: 12))
        }
        .foregroundStyle(.blackPrimary)
    }

    private func save() {
        Task {
            if let profile = await viewModel.save() {
                onSaved(profile)
                dismiss()
            }
        }
    }
}
