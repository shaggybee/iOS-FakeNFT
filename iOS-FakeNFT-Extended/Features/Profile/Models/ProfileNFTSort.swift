import Foundation

enum ProfileNFTSort: String, CaseIterable, Sendable {
    case price
    case rating
    case name

    var title: String {
        switch self {
        case .price: NSLocalizedString("ProfileNFT.sort.price", comment: "NFT sorting by price")
        case .rating: NSLocalizedString("ProfileNFT.sort.rating", comment: "NFT sorting by rating")
        case .name: NSLocalizedString("ProfileNFT.sort.name", comment: "NFT sorting by name")
        }
    }

    func sorted(_ items: [Nft]) -> [Nft] {
        items.sorted { lhs, rhs in
            switch self {
            case .price where lhs.price != rhs.price:
                return lhs.price < rhs.price
            case .rating where lhs.rating != rhs.rating:
                return lhs.rating > rhs.rating
            default:
                let nameOrder = lhs.name.localizedCaseInsensitiveCompare(rhs.name)
                return nameOrder == .orderedSame ? lhs.id < rhs.id : nameOrder == .orderedAscending
            }
        }
    }
}

@MainActor
protocol ProfileNFTSortStoring: AnyObject {
    var selection: ProfileNFTSort { get set }
}

@MainActor
final class ProfileNFTSortStore: ProfileNFTSortStoring {
    private let defaults: UserDefaults
    private let key = "Profile.myNFTs.sort"

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    var selection: ProfileNFTSort {
        get { defaults.string(forKey: key).flatMap(ProfileNFTSort.init(rawValue:)) ?? .rating }
        set { defaults.set(newValue.rawValue, forKey: key) }
    }
}
