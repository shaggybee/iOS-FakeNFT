import Foundation

struct UserProfile: Decodable, Equatable, Sendable, Identifiable {
    let id: String
    let name: String
    let avatar: String
    let description: String
    let website: String
    let nfts: [String]
    let likes: [String]

    var avatarURL: URL? { ProfileURL.webURL(from: avatar) }
    var websiteURL: URL? { ProfileURL.webURL(from: website) }
}

enum ProfileURL {
    static func webURL(from value: String) -> URL? {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty,
              let components = URLComponents(string: value),
              let scheme = components.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              let host = components.host, !host.isEmpty,
              components.user == nil, components.password == nil else { return nil }
        return components.url
    }
}

struct ProfileDraft: Equatable, Sendable {
    var name: String
    var description: String
    var website: String
    var avatar: String

    init(profile: UserProfile) {
        name = profile.name
        description = profile.description
        website = profile.website
        avatar = profile.avatar
    }

    func changedFields(comparedTo profile: UserProfile) -> [String: String] {
        let pairs = [
            ("name", name.trimmingCharacters(in: .whitespacesAndNewlines), profile.name),
            ("description", description, profile.description),
            ("website", website.trimmingCharacters(in: .whitespacesAndNewlines), profile.website),
            ("avatar", avatar.trimmingCharacters(in: .whitespacesAndNewlines), profile.avatar)
        ]
        return Dictionary(uniqueKeysWithValues: pairs.compactMap { key, value, previous in
            value == previous ? nil : (key, value)
        })
    }

    var validationMessage: String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Введите имя."
        }
        if !website.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           ProfileURL.webURL(from: website) == nil {
            return "Укажите адрес сайта, начинающийся с https:// или http://."
        }
        if !avatar.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           ProfileURL.webURL(from: avatar) == nil {
            return "Укажите ссылку на фото, начинающуюся с https:// или http://."
        }
        return nil
    }
}
