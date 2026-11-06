import SwiftUI

struct ProfileFavoritesRootView: View {
    @Environment(ServicesAssembly.self) private var services
    let onProfileChanged: (UserProfile) -> Void

    var body: some View {
        ProfileFavoritesView(viewModel: ProfileFavoritesViewModel(
            service: services.profileFavoritesService,
            onProfileChanged: onProfileChanged
        ))
    }
}

struct ProfileFavoritesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProfileFavoritesViewModel
    @State private var request = Request.initial

    private enum Request: Hashable {
        case initial
        case retry(UUID)
        case remove(String, UUID)
    }

    init(viewModel: ProfileFavoritesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        content
            .background(.whitePrimary)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(.backward24) }
                        .accessibilityLabel(Text("ProfileNFT.back"))
                        .accessibilityIdentifier("profile.favorites.back")
                }
            }
            .tint(.blackPrimary)
            .alert("ProfileFavorites.error.title", isPresented: $viewModel.showsError) {
                Button("Error.repeat") { request = .retry(UUID()) }
                Button("ProfileNFT.cancel", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .task(id: request) {
                switch request {
                case .initial: await viewModel.loadIfNeeded()
                case .retry: await viewModel.retry()
                case .remove(let id, _): await viewModel.remove(id: id)
                }
            }
    }

    private var title: String {
        if case .loaded(let items) = viewModel.state, items.isEmpty { return "" }
        return NSLocalizedString("ProfileFavorites.title", comment: "Favorites screen title")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()
        case .loaded(let items) where items.isEmpty:
            EmptyStateView(message: NSLocalizedString("ProfileFavorites.empty", comment: "Empty favorites"))
        case .loaded(let items):
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                          alignment: .leading, spacing: 20) {
                    ForEach(items) { item in
                        ProfileFavoriteCell(item: item, isRemoving: viewModel.removingID == item.id) {
                            request = .remove(item.id, UUID())
                        }
                        .disabled(viewModel.isBusy)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 16)
            }
            .refreshable { await viewModel.load() }
        case .error:
            ErrorStateView(message: viewModel.errorMessage) { request = .retry(UUID()) }
                .padding(16)
        }
    }
}

private struct ProfileFavoriteCell: View {
    @Environment(\.locale) private var locale
    let item: Nft
    let isRemoving: Bool
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ProfileNFTArtwork(url: item.images.first)
                .frame(width: 80, height: 80)
                .clipShape(.rect(cornerRadius: 12))
                .accessibilityHidden(true)
                .overlay(alignment: .topTrailing) {
                    Button(action: onRemove) {
                        Group {
                            if isRemoving { ProgressView().tint(.redUniversal) }
                            else { Image(systemName: AppSystemIcon.heartFilled).foregroundStyle(.redUniversal) }
                        }
                        .font(.system(size: 18))
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(format: NSLocalizedString("ProfileFavorites.remove", comment: "Remove NFT"), item.name))
                    .accessibilityIdentifier("profile.favorites.remove." + item.id)
                }
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(AppFont.bold17)
                    .lineLimit(1)
                    .accessibilityIdentifier("profile.favorites.name")
                RatingView(rating: item.rating)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(String(format: NSLocalizedString("ProfileNFT.rating", comment: "Rating"),
                                               max(0, min(5, item.rating))))
                Text(item.price.formatted(.number.locale(locale).precision(.fractionLength(2))) + " ETH")
                    .font(AppFont.regular13)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(.blackPrimary)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
