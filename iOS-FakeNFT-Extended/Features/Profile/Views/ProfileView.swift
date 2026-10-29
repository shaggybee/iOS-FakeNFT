import SwiftUI

struct ProfileRootView: View {
    @Environment(ServicesAssembly.self) private var services

    var body: some View {
        ProfileView(viewModel: ProfileViewModel(service: profileService))
    }

    private var profileService: any ProfileService {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--profile-ui-testing") {
            return ProfileUITestService(
                failsFirstLoad: ProcessInfo.processInfo.arguments.contains("--profile-fail-first-load"),
                unavailableWebsite: ProcessInfo.processInfo.arguments.contains("--profile-unavailable-website")
            )
        }
        #endif
        return services.profileService
    }
}

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var editingProfile: UserProfile?
    @State private var website: ProfileWebsite?

    init(viewModel: ProfileViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            content
                .background(.whitePrimary)
                .toolbar {
                    if case .loaded(let profile) = viewModel.state {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                editingProfile = profile
                            } label: {
                                Image(.edit40)
                            }
                            .accessibilityLabel("Редактировать профиль")
                            .accessibilityIdentifier("profile.edit")
                            .tint(.blackPrimary)
                        }
                    }
                }
                .task { await viewModel.loadIfNeeded() }
                .sheet(item: $website) { site in ProfileWebsiteView(url: site.url) }
                .fullScreenCover(item: $editingProfile) { profile in
                    ProfileEditView(profile: profile, service: viewModel.service) { updated in
                        viewModel.accept(updated)
                    }
                }
                .alert("Не удалось загрузить профиль", isPresented: $viewModel.showsError) {
                    Button("Повторить") { Task { await viewModel.load() } }
                    Button("Отмена", role: .cancel) { }
                } message: {
                    Text(viewModel.errorMessage)
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()
        case .loaded(let profile):
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 16) {
                        ProfileAvatarView(url: profile.avatarURL, size: 70)
                        Text(profile.name)
                            .font(AppFont.bold22)
                            .accessibilityIdentifier("profile.name")
                    }
                    .padding(.top, 20)

                    Text(profile.description)
                        .font(AppFont.regular13)
                        .padding(.top, 20)
                        .accessibilityIdentifier("profile.description")

                    if let url = profile.websiteURL {
                        Button {
                            website = ProfileWebsite(url: url)
                        } label: {
                            Text(profile.website)
                                .font(AppFont.regular15)
                                .foregroundStyle(.blueUniversal)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.top, 12)
                        .accessibilityIdentifier("profile.website")
                    }

                    VStack(spacing: 0) {
                        menuRow("Мои NFT", count: profile.nfts.count)
                        menuRow("Избранные NFT", count: profile.likes.count)
                    }
                    .padding(.top, 28)
                }
                .foregroundStyle(.blackPrimary)
                .padding(.horizontal, 16)
            }
            .refreshable { await viewModel.load() }
            .disabled(viewModel.isLoading)
        case .error:
            ErrorStateView(message: viewModel.errorMessage) {
                Task { await viewModel.load() }
            }
            .padding(16)
        }
    }

    private func menuRow(_ title: String, count: Int) -> some View {
        HStack {
            Text("\(title) (\(count))")
                .font(AppFont.bold17)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(minHeight: 54)
        // Навигация в списки включается во второй и третьей итерациях эпика.
        .accessibilityElement(children: .combine)
    }
}
