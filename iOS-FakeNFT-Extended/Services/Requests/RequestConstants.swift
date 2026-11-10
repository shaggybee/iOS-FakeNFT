import Foundation

enum RequestConstants {
    private static let apiInfoPlistKey = "API_TOKEN"
    
    static let baseURL = "https://d5dn3j2ouj72b0ejucbl.apigw.yandexcloud.net"
    
    static var token: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: apiInfoPlistKey) as? String,
                !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            preconditionFailure("Missing api key")
        }
        
        return apiKey
    }
}
