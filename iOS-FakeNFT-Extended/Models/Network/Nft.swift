import Foundation

struct Nft: Decodable, Equatable, Sendable, Identifiable {
    let id: String
    let images: [URL]
    let name: String
    let rating: Int
    let price: Decimal
    let author: String
}
