import SwiftUI

struct ProfileNFTsRootView: View {
    @Environment(ServicesAssembly.self) private var services
    let profile: UserProfile
    let onProfileChanged: (UserProfile) -> Void

    var body: some View {
        ProfileNFTsView(viewModel: ProfileNFTsViewModel(
            profile: profile,
            service: services.profileNFTsService,
            sortStore: ProfileNFTSortStore(),
            favoritesService: services.profileFavoritesService,
            onProfileChanged: onProfileChanged
        ))
    }

}

struct ProfileNFTsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProfileNFTsViewModel
    @State private var showsSort = false
    @State private var request = Request.initial

    private enum Request: Hashable {
        case initial
        case retry(UUID)
        case setFavorite(String, Bool, UUID)
    }

    init(viewModel: ProfileNFTsViewModel) {
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
                        .accessibilityIdentifier("profile.nfts.back")
                }
                if !viewModel.items.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showsSort = true } label: { Image(.sort40) }
                            .accessibilityLabel(Text("ProfileNFT.sort.title"))
                            .accessibilityValue(viewModel.selection.title)
                            .accessibilityIdentifier("profile.nfts.sort")
                    }
                }
            }
            .tint(.blackPrimary)
            .confirmationDialog("ProfileNFT.sort.title", isPresented: $showsSort, titleVisibility: .visible) {
                ForEach(ProfileNFTSort.allCases, id: \.self) { option in
                    Button(option.title) { viewModel.selectSort(option) }
                }
                Button("ProfileNFT.close", role: .cancel) { }
            }
            .alert(LocalizedStringKey(viewModel.errorTitle), isPresented: $viewModel.showsError) {
                Button("Error.repeat") { request = .retry(UUID()) }
                Button("ProfileNFT.cancel", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .task(id: request) {
                switch request {
                case .initial: await viewModel.loadIfNeeded()
                case .retry: await viewModel.retry()
                case .setFavorite(let id, let isLiked, _): await viewModel.setFavorite(id: id, isLiked: isLiked)
                }
            }
    }

    private var title: String {
        if case .loaded(let items) = viewModel.state, items.isEmpty { return "" }
        return NSLocalizedString("ProfileNFT.title", comment: "Owned NFTs screen title")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()
        case .empty:
            EmptyStateView(message: NSLocalizedString("ProfileNFT.empty", comment: "No owned NFTs"))
                .accessibilityIdentifier("profile.nfts.loading")
        case .loaded(let items) where items.isEmpty:
            EmptyStateView(message: NSLocalizedString("ProfileNFT.empty", comment: "No owned NFTs"))
        case .loaded:
            List(viewModel.items) { item in
                ProfileNFTCell(item: item, isLiked: viewModel.likedIDs.contains(item.id),
                               isUpdating: viewModel.updatingFavoriteID == item.id,
                               isEnabled: !viewModel.isBusy) {
                    request = .setFavorite(item.id, !viewModel.likedIDs.contains(item.id), UUID())
                }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.whitePrimary)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .padding(.top, 24)
            .refreshable { await viewModel.load() }
        case .error:
            ErrorStateView(message: viewModel.errorMessage) {
                request = .retry(UUID())
            }
            .padding(16)
        }
    }
}
