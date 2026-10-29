import Foundation

enum ProfileNFTSort: String, CaseIterable, Sendable {
    case price
    case rating
    case name

    var title: String {
        switch self {
        case .price: "По цене"
        case .rating: "По рейтингу"
        case .name: "По названию"
        }
    }

    func sorted(_ items: [ProfileNFT]) -> [ProfileNFT] {
        items.sorted { lhs, rhs in
            switch self {
            case .price where lhs.nft.price != rhs.nft.price:
                return lhs.nft.price < rhs.nft.price
            case .rating where lhs.nft.rating != rhs.nft.rating:
                return lhs.nft.rating > rhs.nft.rating
            default:
                let nameOrder = lhs.nft.name.localizedCaseInsensitiveCompare(rhs.nft.name)
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
