import Foundation

struct Nft: Decodable, Sendable, Identifiable {
    let id: String
    let name: String
    let images: [URL]
    let description: String
    let rating: Int
    let price: Double
    let author: String
}
