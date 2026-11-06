import Foundation
import Observation

@Observable
@MainActor
final class ProfileNFTsViewModel {
    private(set) var state: ViewState<[ProfileNFT]> = .idle
    private(set) var selection: ProfileNFTSort
    private(set) var errorMessage = ""
    var showsError = false
    let likedIDs: Set<String>
    private let nftIDs: [String]
    private let service: any ProfileNFTsService
    private let sortStore: any ProfileNFTSortStoring

    init(profile: UserProfile, service: any ProfileNFTsService, sortStore: any ProfileNFTSortStoring) {
        nftIDs = profile.nfts
        likedIDs = Set(profile.likes)
        self.service = service
        self.sortStore = sortStore
        selection = sortStore.selection
    }

    var items: [ProfileNFT] {
        guard case .loaded(let items) = state else { return [] }
        return selection.sorted(items)
    }

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
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
        guard !isLoading else { return }
        let previous = state
        state = .loading
        showsError = false
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
}
