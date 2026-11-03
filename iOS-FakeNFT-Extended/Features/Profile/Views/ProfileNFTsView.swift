import SwiftUI

struct ProfileNFTsRootView: View {
    @Environment(ServicesAssembly.self) private var services
    let profile: UserProfile

    var body: some View {
        ProfileNFTsView(viewModel: ProfileNFTsViewModel(
            profile: profile,
            service: services.profileNFTsService,
            sortStore: ProfileNFTSortStore()
        ))
    }

}

struct ProfileNFTsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProfileNFTsViewModel
    @State private var showsSort = false
    @State private var loadID = 0

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
            .alert("ProfileNFT.error.title", isPresented: $viewModel.showsError) {
                Button("Error.repeat") { loadID += 1 }
                Button("ProfileNFT.cancel", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .task(id: loadID) {
                if loadID == 0 { await viewModel.loadIfNeeded() }
                else { await viewModel.load() }
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
                .accessibilityIdentifier("profile.nfts.loading")
        case .loaded(let items) where items.isEmpty:
            EmptyStateView(message: NSLocalizedString("ProfileNFT.empty", comment: "No owned NFTs"))
        case .loaded:
            List(viewModel.items) { item in
                ProfileNFTCell(item: item, isLiked: viewModel.likedIDs.contains(item.id))
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
                loadID += 1
            }
            .padding(16)
        }
    }
}
