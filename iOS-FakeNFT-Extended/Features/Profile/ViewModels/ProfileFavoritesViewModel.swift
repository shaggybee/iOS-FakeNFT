import Foundation
import Observation

@Observable
@MainActor
final class ProfileFavoritesViewModel {
    private(set) var state: ViewState<[Nft]> = .idle
    private(set) var removingID: String?
    private(set) var errorMessage = ""
    var showsError = false
    private var failedRemovalID: String?
    private let service: any ProfileFavoritesService
    private let onProfileChanged: (UserProfile) -> Void

    init(service: any ProfileFavoritesService, onProfileChanged: @escaping (UserProfile) -> Void) {
        self.service = service
        self.onProfileChanged = onProfileChanged
    }

    var items: [Nft] {
        guard case .loaded(let items) = state else { return [] }
        return items
    }

    var isBusy: Bool {
        if case .loading = state { return true }
        return removingID != nil
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
        failedRemovalID = nil
        do {
            let snapshot = try await service.loadFavorites()
            try Task.checkCancellation()
            state = .loaded(snapshot.items)
            onProfileChanged(snapshot.profile)
        } catch {
            if Task.isCancelled || error is CancellationError {
                state = previous
                return
            }
            errorMessage = ProfileErrorMessage.text(for: error)
            state = .error(error)
            showsError = true
        }
    }

    func remove(id: String) async {
        guard !isBusy, items.contains(where: { $0.id == id }) else { return }
        removingID = id
        showsError = false
        var confirmedProfile: UserProfile?
        defer { removingID = nil }
        do {
            let profile = try await service.removeFavorite(id: id)
            try Task.checkCancellation()
            confirmedProfile = profile
            failedRemovalID = nil
            let byID = Dictionary(items.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
            if profile.likes.contains(where: { byID[$0] == nil }) {
                let snapshot = try await service.loadFavorites()
                try Task.checkCancellation()
                state = .loaded(snapshot.items)
                onProfileChanged(snapshot.profile)
            } else {
                var seen = Set<String>()
                state = .loaded(profile.likes.compactMap { id in
                    seen.insert(id).inserted ? byID[id] : nil
                })
                onProfileChanged(profile)
            }
        } catch {
            guard !Task.isCancelled, !(error is CancellationError) else { return }
            if let profile = confirmedProfile {
                // The PUT succeeded: retry the snapshot load, not the mutation.
                state = .error(error)
                failedRemovalID = nil
                onProfileChanged(profile)
            } else {
                failedRemovalID = id
            }
            errorMessage = ProfileErrorMessage.text(for: error)
            showsError = true
        }
    }

    func retry() async {
        if let id = failedRemovalID { await remove(id: id) }
        else { await load() }
    }
}
