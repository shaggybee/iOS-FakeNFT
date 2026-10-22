import Foundation

struct Nft: Decodable, Sendable, Identifiable {
    let id: String
    let name: String
    let images: [URL]
    let rating: Int
    let price: Double
    let description: String
    let author: String
}
