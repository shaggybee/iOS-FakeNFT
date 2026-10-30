//
//  MockUsersService.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 30.10.2026.
//

import Foundation

enum MockUsersServiceError: Error {
    case userNotFound
}

struct MockUsersService: UsersService {
    
    private let users: [User] = [
        User(
            id: "1",
            name: "Joaquin Phoenix",
            avatar: "",
            description: "Дизайнер из Казани, люблю цифровое искусство.",
            website: "https://example.com",
            nfts: ["101", "102", "103"],
            rating: "1"
        ),
        User(
            id: "2",
            name: "Alex Morgan",
            avatar: "",
            description: "Коллекционирую цифровое искусство.",
            website: "https://example.org",
            nfts: ["201", "202"],
            rating: "1"
        )
    ]
    
    func loadUsers() async throws -> [User] {
        return users
    }
        
    func loadUser(id: String) async throws -> User {
        guard let user = users.first(where: { $0.id == id }) else {
            throw MockUsersServiceError.userNotFound
        }
        
        return user
    }
}
