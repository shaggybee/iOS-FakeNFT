//
//  UsersService.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 23.10.2026.
//

import Foundation

protocol UsersService {
    func loadUsers() async throws -> [User]
    func loadUser(id: String) async throws -> User
}

@MainActor
final class UsersServiceImpl: UsersService {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }
    
    func loadUsers() async throws -> [User] {
        let request = UsersRequest()
        let users: [User] = try await networkClient.send(request: request)
        return users
    }
    
    func loadUser(id: String) async throws -> User {
        let request = UserByIdRequest(id: id)
        let user: User = try await networkClient.send(request: request)
        return user
    }

}
