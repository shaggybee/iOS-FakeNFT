//
//  CatalogSortStorage.swift
//  iOS-FakeNFT-Extended
//
//  Created by Anastasia Belyakova on 31.10.2026.
//

import Foundation

// MARK: - CatalogSortStorageProtocol

protocol CatalogSortStorageProtocol {
    func loadSortOption() -> CatalogSortOption?
    func saveSortOption(_ option: CatalogSortOption)
}

// MARK: - CatalogSortStorageImpl

final class CatalogSortStorageImpl: CatalogSortStorageProtocol {

    // MARK: - Properties

    private let userDefaults: UserDefaults

    // MARK: - Init

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Public Methods

    func loadSortOption() -> CatalogSortOption? {
        userDefaults.string(forKey: Constants.sortOptionKey).flatMap(CatalogSortOption.init(rawValue:))
    }

    func saveSortOption(_ option: CatalogSortOption) {
        userDefaults.set(option.rawValue, forKey: Constants.sortOptionKey)
    }
}

// MARK: - Constants

private extension CatalogSortStorageImpl {
    enum Constants {
        static let sortOptionKey = "catalogSortOption"
    }
}
