import SwiftUI

struct ProfileNFTsRootView: View {
    @Environment(ServicesAssembly.self) private var services
    let profile: UserProfile

    var body: some View {
        ProfileNFTsView(viewModel: ProfileNFTsViewModel(
            profile: profile,
            service: nftService,
            sortStore: ProfileNFTSortStore()
        ))
    }

    private var nftService: any ProfileNFTsService {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("--profile-ui-testing") {
            return ProfileNFTsUITestService(
                failsFirstLoad: ProcessInfo.processInfo.arguments.contains("--profile-nfts-fail-first-load")
            )
        }
        #endif
        return services.profileNFTsService
    }
}

struct ProfileNFTsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ProfileNFTsViewModel
    @State private var showsSort = false

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
                        .accessibilityLabel("Назад")
                        .accessibilityIdentifier("profile.nfts.back")
                }
                if !viewModel.items.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button { showsSort = true } label: { Image(.sort40) }
                            .accessibilityLabel("Сортировка")
                            .accessibilityValue(viewModel.selection.title)
                            .accessibilityIdentifier("profile.nfts.sort")
                    }
                }
            }
            .tint(.blackPrimary)
            .confirmationDialog("Сортировка", isPresented: $showsSort, titleVisibility: .visible) {
                ForEach(ProfileNFTSort.allCases, id: \.self) { option in
                    Button(option.title) { viewModel.selectSort(option) }
                }
                Button("Закрыть", role: .cancel) { }
            }
            .alert("Не удалось загрузить NFT", isPresented: $viewModel.showsError) {
                Button("Повторить") { Task { await viewModel.load() } }
                Button("Отмена", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .task { await viewModel.loadIfNeeded() }
    }

    private var title: String {
        if case .loaded(let items) = viewModel.state, items.isEmpty { return "" }
        return "Мои NFT"
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()
        case .loaded(let items) where items.isEmpty:
            EmptyStateView(message: "У Вас ещё нет NFT")
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
                Task { await viewModel.load() }
            }
            .padding(16)
        }
    }
}
