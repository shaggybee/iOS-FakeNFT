import Foundation
import Observation

@Observable
@MainActor
final class ProfileNFTsViewModel {
    private(set) var state: ViewState<[Nft]> = .idle
    private(set) var selection: ProfileNFTSort
    private(set) var errorMessage = ""
    var showsError = false
    private(set) var likedIDs: Set<String>
    private(set) var updatingFavoriteID: String?
    private var failedFavoriteChange: (id: String, isLiked: Bool)?
    private let nftIDs: [String]
    private let service: any ProfileNFTsService
    private let sortStore: any ProfileNFTSortStoring
    private let favoritesService: any ProfileFavoritesService
    private let onProfileChanged: (UserProfile) -> Void

    init(profile: UserProfile, service: any ProfileNFTsService, sortStore: any ProfileNFTSortStoring,
         favoritesService: any ProfileFavoritesService, onProfileChanged: @escaping (UserProfile) -> Void = { _ in }) {
        nftIDs = profile.nfts
        likedIDs = Set(profile.likes)
        self.service = service
        self.sortStore = sortStore
        self.favoritesService = favoritesService
        self.onProfileChanged = onProfileChanged
        selection = sortStore.selection
    }

    var items: [Nft] {
        guard case .loaded(let items) = state else { return [] }
        return selection.sorted(items)
    }

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    var isBusy: Bool { isLoading || updatingFavoriteID != nil }
    var errorTitle: String {
        failedFavoriteChange == nil ? "ProfileNFT.error.title" : "ProfileFavorites.error.title"
    }

    func selectSort(_ selection: ProfileNFTSort) {
        self.selection = selection
        sortStore.selection = selection
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    func load() async {
        guard !isBusy else { return }
        let previous = state
        state = .loading
        showsError = false
        failedFavoriteChange = nil
        do {
            let items = try await service.loadNFTs(ids: nftIDs)
            try Task.checkCancellation()
            state = .loaded(items)
        } catch is CancellationError {
            state = previous
        } catch {
            guard !Task.isCancelled else {
                state = previous
                return
            }
            errorMessage = ProfileErrorMessage.text(for: error)
            state = .error(error)
            showsError = true
        }
    }

    func retry() async {
        if let change = failedFavoriteChange {
            await setFavorite(id: change.id, isLiked: change.isLiked)
        } else {
            await load()
        }
    }

    func setFavorite(id: String, isLiked: Bool) async {
        guard !isBusy, items.contains(where: { $0.id == id }) else { return }
        updatingFavoriteID = id
        showsError = false
        defer { updatingFavoriteID = nil }
        do {
            // Set an explicit state so retry cannot invert a PUT already accepted by the server.
            let profile = try await favoritesService.setFavorite(id: id, isLiked: isLiked)
            try Task.checkCancellation()
            likedIDs = Set(profile.likes)
            failedFavoriteChange = nil
            onProfileChanged(profile)
        } catch {
            guard !Task.isCancelled, !(error is CancellationError) else { return }
            failedFavoriteChange = (id, isLiked)
            errorMessage = ProfileErrorMessage.text(for: error)
            showsError = true
        }
    }
}
