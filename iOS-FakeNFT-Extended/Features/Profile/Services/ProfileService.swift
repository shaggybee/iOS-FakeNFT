import Foundation

protocol ProfileService: Sendable {
    func loadProfile() async throws -> UserProfile
    func updateProfile(fields: [String: String]) async throws -> UserProfile
    func updateLikes(_ ids: [String]) async throws -> UserProfile
}

actor ProfileServiceImpl: ProfileService {
    private let networkClient: any NetworkClient

    init(networkClient: any NetworkClient) {
        self.networkClient = networkClient
    }

    func loadProfile() async throws -> UserProfile {
        try await networkClient.send(request: ProfileRequest())
    }

    func updateProfile(fields: [String: String]) async throws -> UserProfile {
        try await networkClient.send(request: ProfileRequest(fields: fields))
    }

    func updateLikes(_ ids: [String]) async throws -> UserProfile {
        try await networkClient.send(request: ProfileLikesUpdateRequest(ids: ids))
    }
}

struct ProfileRequest: NetworkRequest {
    let fields: [String: String]?

    init(fields: [String: String]? = nil) {
        self.fields = fields
    }

    var endpoint: URL? { URL(string: RequestConstants.baseURL + "/api/v1/profile/1") }
    var httpMethod: HttpMethod { fields == nil ? .get : .put }
    var formParameters: [URLQueryItem]? {
        fields?.sorted { $0.key < $1.key }.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}

struct ProfileLikesUpdateRequest: NetworkRequest {
    let ids: [String]
    var endpoint: URL? { URL(string: RequestConstants.baseURL + "/api/v1/profile/1") }
    var httpMethod: HttpMethod { .put }
    var formParameters: [URLQueryItem]? {
        ids.isEmpty ? [URLQueryItem(name: "likes", value: "null")]
            : ids.map { URLQueryItem(name: "likes", value: $0) }
    }
}

enum ProfileErrorMessage {
    static func text(for error: Error) -> String {
        if let error = error as? URLError, error.code == .notConnectedToInternet {
            return "Нет подключения к интернету. Проверьте соединение и попробуйте ещё раз."
        }
        if let error = error as? NetworkClientError {
            switch error {
            case .httpStatusCode(let code) where code == 401 || code == 403:
                return "Сервер отклонил запрос. Проверьте учебный API-токен."
            case .parsingError:
                return "Сервер вернул данные в неожиданном формате. Попробуйте ещё раз позже."
            default:
                break
            }
        }
        return "Не удалось получить ответ сервера. Попробуйте ещё раз."
    }
}
