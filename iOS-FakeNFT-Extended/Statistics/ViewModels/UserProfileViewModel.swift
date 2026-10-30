//
//  UserProfileViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 30.10.2026.
//

import Foundation
import Observation

@Observable
@MainActor

final class UserProfileViewModel {
    
    private let userId: String
    private let usersService: UsersService
    
    private(set) var user: User? = nil
    
    var isLoading = false
    var errorMessage: String?
    
    init(userId: String, usersService: UsersService) {
        self.userId = userId
        self.usersService = usersService
    }
    
    func loadUser() async {
        isLoading = true
        errorMessage = nil
        user = nil
        
        defer {
            isLoading = false
        }
        
        do {
            self.user = try await usersService.loadUser(id: userId)
        } catch {
            errorMessage = "Не удалось найти пользователя"
        }
    }
}

