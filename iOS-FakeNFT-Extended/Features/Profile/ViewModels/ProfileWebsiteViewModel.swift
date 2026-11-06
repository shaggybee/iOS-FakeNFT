import Foundation
import Observation

@Observable
@MainActor
final class ProfileWebsiteViewModel {
    enum State: Equatable {
        case loading
        case loaded
        case failed
    }

    private(set) var state: State = .loading
    private(set) var reloadID = 0

    func startedLoading() { state = .loading }

    func finishedLoading() { state = .loaded }

    func failedLoading(with error: Error) {
        let error = error as NSError
        guard error.domain != NSURLErrorDomain || error.code != NSURLErrorCancelled else { return }
        state = .failed
    }

    func retry() {
        guard state == .failed else { return }
        state = .loading
        reloadID += 1
    }
}
