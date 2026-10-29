import Foundation

struct NFTAuthor: Decodable, Equatable, Sendable {
    let id: String
    let name: String
}

struct ProfileNFT: Identifiable, Equatable, Sendable {
    let nft: Nft
    let author: NFTAuthor
    var id: String { nft.id }
}
