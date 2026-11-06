import Foundation

struct Nft: Decodable, Equatable, Sendable, Identifiable {
    let id: String
    let name: String
    let images: [URL]
    let rating: Int
    let price: Double
    let description: String
    let author: String

    init(id: String, name: String, images: [URL], rating: Int, price: Double,
         description: String = "", author: String) {
        self.id = id
        self.name = name
        self.images = images
        self.rating = rating
        self.price = price
        self.description = description
        self.author = author
    }

    init(id: String, images: [URL], name: String, rating: Int, price: Double, author: String) {
        self.init(id: id, name: name, images: images, rating: rating, price: price, author: author)
    }

    private enum CodingKeys: String, CodingKey { case id, name, images, rating, price, description, author }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        images = try values.decode([URL].self, forKey: .images)
        rating = try values.decode(Int.self, forKey: .rating)
        price = try values.decode(Double.self, forKey: .price)
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        author = try values.decode(String.self, forKey: .author)
    }
}
