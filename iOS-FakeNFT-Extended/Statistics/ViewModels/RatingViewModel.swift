//
//  RatingViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 23.10.2026.
//

import Foundation
import Observation

@Observable
@MainActor

final class RatingViewModel {
    
    private let usersService: UsersService
    
    init(usersService: UsersService) {
        self.usersService = usersService
    }
    
    private var sortOption = UserDefaults.standard.string(forKey: "statisticsSortOption") ?? "rating"
    
    var isLoading = false
    var errorMessage: String? = nil
    
    var users: [RatingUser] = []
    
    func sortByName() {
        sortOption = "name"
        UserDefaults.standard.set(sortOption, forKey: "statisticsSortOption")
        
        users.sort { $0.name < $1.name }
    }
    
    func sortByRating() {
        sortOption = "rating"
        UserDefaults.standard.set(sortOption, forKey: "statisticsSortOption")
        
        users.sort { $0.nftCount > $1.nftCount }
    }

    func loadUsers() async {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        do {
            let usersFromAPI = try await usersService.loadUsers()
            
            users = usersFromAPI.map { user in
                RatingUser(id: user.id, name: user.name, avatar: user.avatar, nftCount: user.nfts.count)
            }
                
                if sortOption == "name" {
                    users.sort { $0.name < $1.name }
                } else {
                    users.sort { $0.nftCount > $1.nftCount }
                }
            
        } catch {
            errorMessage = "Не удалось загрузить пользователей"
        }
    }
}
