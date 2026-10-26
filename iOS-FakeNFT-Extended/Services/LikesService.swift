//
//  LikesService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

protocol LikesService: Sendable {
    func loadLikes() async throws -> Set<String>
    func updateLikes(_ likes: Set<String>) async throws
}

@MainActor
final class LikesServiceImpl: LikesService {

    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    func loadLikes() async throws -> Set<String> {
        let profile: ProfileLikes = try await networkClient.send(request: ProfileLikesRequest())
        return Set(profile.likes)
    }

    func updateLikes(_ likes: Set<String>) async throws {
        let request = UpdateLikesRequest(likes: likes.sorted())
        _ = try await networkClient.send(request: request)
    }
}
