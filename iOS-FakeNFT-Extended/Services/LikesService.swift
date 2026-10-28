//
//  LikesService.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 26.10.2026.
//

import Foundation

// MARK: - LikesServiceProtocol

protocol LikesServiceProtocol: Sendable {
    func loadLikes() async throws -> Set<String>
    func updateLikes(_ likes: Set<String>) async throws
}

// MARK: - LikesServiceImpl

@MainActor
final class LikesServiceImpl: LikesServiceProtocol {

    // MARK: - Properties

    private let networkClient: NetworkClient

    // MARK: - Init

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    // MARK: - Public Methods

    func loadLikes() async throws -> Set<String> {
        let profile: ProfileLikes = try await networkClient.send(request: ProfileLikesRequest())
        return Set(profile.likes)
    }

    func updateLikes(_ likes: Set<String>) async throws {
        let request = UpdateLikesRequest(likes: likes.sorted())
        _ = try await networkClient.send(request: request)
    }
}
