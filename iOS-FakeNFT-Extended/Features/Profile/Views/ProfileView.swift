import SwiftUI

struct ProfileRootView: View {
    @Environment(ServicesAssembly.self) private var services

    var body: some View {
        ProfileView(viewModel: ProfileViewModel(service: services.profileService))
    }

}

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    @State private var editingProfile: UserProfile?
    @State private var website: ProfileWebsite?
    @State private var loadID = 0

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
                            .accessibilityLabel(Text("Profile.edit"))
                            .accessibilityIdentifier("profile.edit")
                            .tint(.blackPrimary)
                        }
                    }
                }
                .task(id: loadID) { await viewModel.load() }
                .sheet(item: $website) { site in ProfileWebsiteView(url: site.url) }
                .fullScreenCover(item: $editingProfile) { profile in
                    ProfileEditView(profile: profile, service: viewModel.service) { updated in
                        viewModel.accept(updated)
                    }
                }
                .alert("Profile.error.title", isPresented: $viewModel.showsError) {
                    Button("Error.repeat") { loadID += 1 }
                    Button("Common.cancel", role: .cancel) { }
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
                        NavigationLink {
                            ProfileNFTsRootView(profile: profile) { updated in viewModel.accept(updated) }
                        } label: {
                            menuRow("ProfileNFT.title", count: profile.nfts.count)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(menuTitle("ProfileNFT.title", count: profile.nfts.count))
                        .accessibilityIdentifier("profile.my-nfts")
                        NavigationLink {
                            ProfileFavoritesRootView { updated in viewModel.accept(updated) }
                        } label: {
                            menuRow("ProfileFavorites.title", count: profile.likes.count)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("profile.favorites")
                    }
                    .padding(.top, 28)
                }
                .foregroundStyle(.blackPrimary)
                .padding(.horizontal, 16)
            }
            .refreshable { await viewModel.load() }
            .disabled(viewModel.isLoading)
        case .error, .empty:
            ErrorStateView(message: viewModel.errorMessage) {
                loadID += 1
            }
            .padding(16)
        }
    }

    private func menuTitle(_ title: String, count: Int) -> String {
        String(format: NSLocalizedString("Profile.menuCount", comment: "Profile menu with NFT count"),
               NSLocalizedString(title, comment: "Profile menu title"), count)
    }

    private func menuRow(_ title: String, count: Int) -> some View {
        HStack {
            Text(menuTitle(title, count: count))
                .font(AppFont.bold17)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(minHeight: 54)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}
