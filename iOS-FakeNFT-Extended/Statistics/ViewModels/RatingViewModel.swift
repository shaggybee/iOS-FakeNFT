//
//  RatingViewModel.swift
//  iOS-FakeNFT-Extended
//
//  Created by el on 23.10.2026.
//

import Foundation
import Observation

enum RatingSortOption: String {
    case name
    case rating
}

private enum Constants {
    static let sortOptionKey = "statisticsSortOption"
}

@Observable
@MainActor

final class RatingViewModel {
    
    private let usersService: UsersService
    private var sortOption: RatingSortOption = {
        let savedValue = UserDefaults.standard.string(forKey: Constants.sortOptionKey) ?? "rating"
        return RatingSortOption(rawValue: savedValue) ?? .rating
    }()

    var isLoading = false
    var errorMessage: String? 
    
    var users: [RatingUser] = []
    
    init(usersService: UsersService) {
        self.usersService = usersService
    }
    
    private func applySorting() {
        switch sortOption {
        case .name:
            users.sort { $0.name < $1.name }
        case .rating:
            users.sort { $0.nftCount > $1.nftCount }
        }
    }
    
    func sortUsers(by option: RatingSortOption) {
        sortOption = option
        UserDefaults.standard.set(sortOption.rawValue, forKey: Constants.sortOptionKey)
        applySorting()
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
            
            applySorting()
            
        } catch {
            errorMessage = "Не удалось загрузить пользователей"
        }
    }
}
