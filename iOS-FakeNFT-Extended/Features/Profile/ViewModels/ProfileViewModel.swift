import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    private(set) var state: ViewState<UserProfile> = .idle
    var showsError = false
    private(set) var errorMessage = ""
    let service: any ProfileService

    init(service: any ProfileService) {
        self.service = service
    }

    var isLoading: Bool {
        if case .loading = state { return true }
        return false
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    func load() async {
        guard !isLoading else { return }
        let previous = state
        state = .loading
        do {
            let profile = try await service.loadProfile()
            try Task.checkCancellation()
            state = .loaded(profile)
        } catch is CancellationError {
            state = previous
        } catch {
            if Task.isCancelled {
                state = previous
                return
            }
            errorMessage = ProfileErrorMessage.text(for: error)
            state = .error(error)
            showsError = true
        }
    }

    func accept(_ profile: UserProfile) {
        state = .loaded(profile)
    }
}
