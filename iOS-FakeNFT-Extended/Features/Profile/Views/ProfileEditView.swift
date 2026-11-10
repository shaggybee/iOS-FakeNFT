import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProfileEditViewModel
    @State private var showsPhotoActions = false
    @State private var showsPhotoURL = false
    @State private var photoURL = ""
    @State private var showsDiscardConfirmation = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case name
        case description
        case website
    }

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

                    field("ProfileEdit.name", identifier: "name") {
                        TextField("ProfileEdit.name", text: $viewModel.draft.name)
                            .textContentType(.name)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.done)
                            .accessibilityIdentifier("profile.edit.name")
                    }

                    field("ProfileEdit.description", identifier: "description") {
                        TextField("ProfileEdit.description", text: $viewModel.draft.description, axis: .vertical)
                            .lineLimit(5...8)
                            .focused($focusedField, equals: .description)
                            .accessibilityIdentifier("profile.edit.description")
                    }

                    field("ProfileEdit.website", identifier: "website") {
                        TextField("ProfileEdit.website.placeholder", text: $viewModel.draft.website)
                            .keyboardType(.URL)
                            .textContentType(.URL)
                            .focused($focusedField, equals: .website)
                            .submitLabel(.done)
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
                .background {
                    Color.whitePrimary
                        .contentShape(Rectangle())
                        .onTapGesture { focusedField = nil }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background {
                Color.whitePrimary
                    .contentShape(Rectangle())
                    .onTapGesture { focusedField = nil }
            }
            .onSubmit { focusedField = nil }
            .onDisappear { focusedField = nil }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        focusedField = nil
                        if viewModel.hasChanges { showsDiscardConfirmation = true }
                        else { dismiss() }
                    } label: {
                        Image(systemName: "chevron.left")
                    }
                    .accessibilityLabel(Text("ProfileNFT.back"))
                    .accessibilityIdentifier("profile.edit.back")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Common.done") { focusedField = nil }
                        .accessibilityIdentifier("profile.edit.keyboard.done")
                }
            }
            .safeAreaInset(edge: .bottom) {
                BaseButton(title: NSLocalizedString("Common.save", comment: "Save profile")) { save() }
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
            .confirmationDialog("ProfileEdit.photo.actions", isPresented: $showsPhotoActions, titleVisibility: .visible) {
                Button("ProfileEdit.photo.change") {
                    photoURL = viewModel.draft.avatar
                    showsPhotoURL = true
                }
                Button("ProfileEdit.photo.delete", role: .destructive) { viewModel.draft.avatar = "" }
                Button("Common.cancel", role: .cancel) { }
            }
            .alert("ProfileEdit.photo.url", isPresented: $showsPhotoURL) {
                TextField("ProfileEdit.photo.placeholder", text: $photoURL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Button("Common.save") { viewModel.draft.avatar = photoURL }
                Button("Common.cancel", role: .cancel) { }
            }
            .alert("ProfileEdit.discard.title", isPresented: $showsDiscardConfirmation) {
                Button("ProfileEdit.discard.confirm", role: .destructive) { dismiss() }
                Button("ProfileEdit.discard.cancel", role: .cancel) { }
            } message: {
                Text("ProfileEdit.discard.message")
            }
            .alert("ProfileEdit.error.title", isPresented: $viewModel.showsError) {
                Button("Error.repeat") { save() }
                Button("Common.cancel", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .tint(.blackPrimary)
        }
    }

    private var photoButton: some View {
        Button {
            focusedField = nil
            showsPhotoActions = true
        } label: {
            ProfileAvatarView(url: ProfileURL.webURL(from: viewModel.draft.avatar), size: 70)
                .overlay(alignment: .bottomTrailing) {
                    Image(systemName: "camera.circle.fill")
                        .font(.system(size: 24))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.whitePrimary, .blackPrimary)
                }
        }
        .accessibilityLabel(Text("ProfileEdit.photo.actions"))
        .accessibilityIdentifier("profile.edit.photo")
    }

    private func field<Content: View>(_ title: LocalizedStringKey, identifier: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppFont.bold22)
                .accessibilityIdentifier("profile.edit.label." + identifier)
                .onTapGesture { focusedField = nil }
            content()
                .font(AppFont.regular17)
                .padding(12)
                .background(.lightGrey)
                .clipShape(.rect(cornerRadius: 12))
        }
        .foregroundStyle(.blackPrimary)
    }

    private func save() {
        focusedField = nil
        Task {
            if let profile = await viewModel.save() {
                onSaved(profile)
                dismiss()
            }
        }
    }
}
