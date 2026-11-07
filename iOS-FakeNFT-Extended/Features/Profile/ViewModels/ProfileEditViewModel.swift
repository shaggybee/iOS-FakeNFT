import Foundation
import Observation

@Observable
@MainActor
final class ProfileEditViewModel {
    var draft: ProfileDraft
    private(set) var isSaving = false
    private(set) var errorMessage = ""
    var showsError = false
    private let original: UserProfile
    private let service: any ProfileService

    init(profile: UserProfile, service: any ProfileService) {
        original = profile
        draft = ProfileDraft(profile: profile)
        self.service = service
    }

    var hasChanges: Bool { !draft.changedFields(comparedTo: original).isEmpty }
    var validationMessage: String? { draft.validationMessage }
    var canSave: Bool { hasChanges && validationMessage == nil && !isSaving }

    func save() async -> UserProfile? {
        guard canSave else { return nil }
        isSaving = true
        defer { isSaving = false }
        do {
            let profile = try await service.updateProfile(fields: draft.changedFields(comparedTo: original))
            try Task.checkCancellation()
            return profile
        } catch is CancellationError {
            return nil
        } catch {
            guard !Task.isCancelled else { return nil }
            errorMessage = ProfileErrorMessage.text(for: error)
            showsError = true
            return nil
        }
    }
}
