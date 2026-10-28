//
//  LikesServiceMock.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 28.10.2026.
//

import Foundation

actor LikesServiceMock: LikesServiceProtocol {

    // MARK: - Properties

    static let shared = LikesServiceMock()

    private var likes: Set<String>

    // MARK: - Init

    init(likes: Set<String> = ["0", "1", "2"]) {
        self.likes = likes
    }

    // MARK: - Public Methods

    func loadLikes() async throws -> Set<String> {
        likes
    }

    func updateLikes(_ likes: Set<String>) async throws {
        self.likes = likes
    }
}
