import XCTest
import WebKit
@testable import iOS_FakeNFT_Extended

@MainActor
final class iOS_FakeNFT_ExtendedTests: XCTestCase {
    private var profile: UserProfile {
        UserProfile(id: "1", name: "Антон", avatar: "", description: "Коллекционер",
                    website: "https://example.com", nfts: ["1", "2"], likes: ["3"])
    }

    func testOnlyChangedFieldsAreSentWithoutNFTsOrLikes() {
        var draft = ProfileDraft(profile: profile)
        draft.name = "  Новое имя  "
        XCTAssertEqual(draft.changedFields(comparedTo: profile), ["name": "Новое имя"])
    }

    func testEmptyNameIsInvalid() {
        var draft = ProfileDraft(profile: profile)
        draft.name = " \n "
        XCTAssertNotNil(draft.validationMessage)
    }

    func testInvalidAndUnsafeURLsAreRejected() {
        for value in ["javascript:alert(1)", "file:///etc/passwd", "https://", "example.com", "https://user:password@example.com"] {
            XCTAssertNil(ProfileURL.webURL(from: value), value)
        }
    }

    func testHTTPSWebsiteAndOptionalEmptyFieldsAreValid() {
        var draft = ProfileDraft(profile: profile)
        draft.website = ""
        draft.avatar = ""
        XCTAssertNil(draft.validationMessage)
        XCTAssertEqual(ProfileURL.webURL(from: " https://example.com/a?b=c ")?.host, "example.com")
    }

    func testFormEncodingPreservesUnicodePlusAmpersandAndEquals() throws {
        let value = "Антон + NFT & art=100%\nhttps://example.com?a=1&b=2"
        let data = FormURLEncoder.encode(["name": value])
        let encoded = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertTrue(encoded.contains("%2B"))
        XCTAssertTrue(encoded.contains("%26"))
        let components = try XCTUnwrap(URLComponents(string: "https://example.com?" + encoded))
        XCTAssertEqual(components.queryItems?.first?.value, value)
    }

    func testProfileRejectsCorruptedArrayTypes() {
        let json = Data(#"{"id":"1","name":"A","avatar":"","description":"","website":"","nfts":"1,2","likes":[]}"#.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(UserProfile.self, from: json))
    }

    func testServiceUsesProfileGETAndPUT() async throws {
        let client = RecordingNetworkClient(profile: profile)
        let service = ProfileServiceImpl(networkClient: client)
        let loaded = try await service.loadProfile()
        _ = try await service.updateProfile(fields: ["name": "Новое имя"])
        let requests = await client.requests
        XCTAssertEqual(loaded, profile)
        XCTAssertEqual(requests.map(\.path), ["/api/v1/profile/1", "/api/v1/profile/1"])
        XCTAssertEqual(requests.map(\.method), ["GET", "PUT"])
        XCTAssertNil(requests.first?.fields)
        XCTAssertEqual(requests.last?.fields, ["name": "Новое имя"])
    }

    func testDefaultNetworkClientSendsEncodedProfilePUT() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [FormRequestURLProtocol.self]
        let session = URLSession(configuration: configuration)
        defer { session.invalidateAndCancel() }
        let client = DefaultNetworkClient(session: session)
        let data: Data = try await client.send(request: ProfileRequest(fields: [
            "name": "Антон + NFT & art",
            "description": "A=B & C+D"
        ]))
        let request = try JSONDecoder().decode(CapturedFormRequest.self, from: data)
        XCTAssertEqual(request.path, "/api/v1/profile/1")
        XCTAssertEqual(request.method, "PUT")
        XCTAssertEqual(request.contentType, "application/x-www-form-urlencoded")
        XCTAssertEqual(request.body,
                       "description=A%3DB%20%26%20C%2BD&name=%D0%90%D0%BD%D1%82%D0%BE%D0%BD%20%2B%20NFT%20%26%20art")
        let components = try XCTUnwrap(URLComponents(string: "https://example.com?" + request.body))
        let fields = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        XCTAssertEqual(fields, ["name": "Антон + NFT & art", "description": "A=B & C+D"])
    }

    func testWebsiteProvisionalFailureCanRetryWithoutDuplicateLoads() throws {
        let model = ProfileWebsiteViewModel()
        let coordinator = ProfileWebContent.Coordinator(model: model)
        let webView = RecordingProfileWebView()
        let url = try XCTUnwrap(URL(string: "https://example.com"))
        coordinator.load(url, in: webView, reloadID: model.reloadID)
        coordinator.load(url, in: webView, reloadID: model.reloadID)
        XCTAssertEqual(webView.requests.count, 1)
        coordinator.webView(webView, didStartProvisionalNavigation: nil)
        coordinator.webView(webView, didFailProvisionalNavigation: nil, withError: URLError(.notConnectedToInternet))
        XCTAssertEqual(model.state, .failed)

        model.retry()
        model.retry()
        XCTAssertEqual(model.state, .loading)
        XCTAssertEqual(model.reloadID, 1)
        coordinator.load(url, in: webView, reloadID: model.reloadID)
        XCTAssertEqual(webView.requests.map(\.url), [url, url])
        coordinator.webView(webView, didStartProvisionalNavigation: nil)
        coordinator.webView(webView, didFinish: nil)
        XCTAssertEqual(model.state, .loaded)
    }

    func testWebsiteFailureAfterNavigationStartsShowsError() {
        let model = ProfileWebsiteViewModel()
        let coordinator = ProfileWebContent.Coordinator(model: model)
        let webView = RecordingProfileWebView()
        coordinator.webView(webView, didStartProvisionalNavigation: nil)
        coordinator.webView(webView, didFail: nil, withError: URLError(.networkConnectionLost))
        XCTAssertEqual(model.state, .failed)
    }

    func testCancelledWebsiteNavigationDoesNotShowError() {
        let model = ProfileWebsiteViewModel()
        let coordinator = ProfileWebContent.Coordinator(model: model)
        let webView = RecordingProfileWebView()
        coordinator.webView(webView, didStartProvisionalNavigation: nil)
        coordinator.webView(webView, didFailProvisionalNavigation: nil, withError: URLError(.cancelled))
        XCTAssertEqual(model.state, .loading)
        coordinator.webView(webView, didFinish: nil)
        coordinator.webView(webView, didFail: nil, withError: URLError(.cancelled))
        XCTAssertEqual(model.state, .loaded)
    }

    func testLoadingProfileUpdatesState() async {
        let service = StubProfileService(profile: profile)
        let model = ProfileViewModel(service: service)
        await model.loadIfNeeded()
        guard case .loaded(let loaded) = model.state else { return XCTFail("Expected loaded profile") }
        XCTAssertEqual(loaded, profile)
        await model.loadIfNeeded()
        let count = await service.loadCount
        XCTAssertEqual(count, 1)
    }

    func testLoadFailureShowsErrorAndRetryRecovers() async {
        let service = StubProfileService(profile: profile, failures: 1)
        let model = ProfileViewModel(service: service)
        await model.load()
        guard case .error = model.state else { return XCTFail("Expected error") }
        XCTAssertTrue(model.showsError)
        model.showsError = false
        await model.load()
        guard case .loaded = model.state else { return XCTFail("Retry should recover") }
    }

    func testCancelledLoadDoesNotShowError() async {
        let service = StubProfileService(profile: profile, delay: .seconds(1))
        let model = ProfileViewModel(service: service)
        let load = Task { await model.load() }
        await Task.yield()
        load.cancel()
        await load.value
        XCTAssertFalse(model.showsError)
        guard case .idle = model.state else { return XCTFail("Expected initial state after cancellation") }
    }

    func testUnchangedOrInvalidDraftCannotSave() async {
        let service = StubProfileService(profile: profile)
        let model = ProfileEditViewModel(profile: profile, service: service)
        XCTAssertFalse(model.canSave)
        let unchanged = await model.save()
        XCTAssertNil(unchanged)
        model.draft.name = " "
        XCTAssertFalse(model.canSave)
        let invalid = await model.save()
        XCTAssertNil(invalid)
        let count = await service.updateCount
        XCTAssertEqual(count, 0)
    }

    func testSavingReturnsServerProfileAndLeavesCollectionsUntouched() async {
        let service = StubProfileService(profile: profile)
        let model = ProfileEditViewModel(profile: profile, service: service)
        model.draft.name = "Новое имя"
        let saved = await model.save()
        XCTAssertEqual(saved?.name, "Новое имя")
        XCTAssertEqual(saved?.nfts, profile.nfts)
        XCTAssertEqual(saved?.likes, profile.likes)
        XCTAssertFalse(model.isSaving)
    }

    func testFailedSavePreservesDraftAndCanBeRetried() async {
        let service = StubProfileService(profile: profile, failures: 1)
        let model = ProfileEditViewModel(profile: profile, service: service)
        model.draft.description = "Новое описание"
        let failed = await model.save()
        XCTAssertNil(failed)
        XCTAssertTrue(model.showsError)
        XCTAssertEqual(model.draft.description, "Новое описание")
        XCTAssertFalse(model.isSaving)
        let saved = await model.save()
        XCTAssertEqual(saved?.description, "Новое описание")
    }

    func testRepeatedSaveDoesNotSendDuplicateRequest() async {
        let service = StubProfileService(profile: profile, delay: .milliseconds(30))
        let model = ProfileEditViewModel(profile: profile, service: service)
        model.draft.name = "Новое имя"
        async let first = model.save()
        async let second = model.save()
        _ = await (first, second)
        let count = await service.updateCount
        XCTAssertEqual(count, 1)
    }

    func testAcceptingSavedProfileUpdatesMainScreen() async {
        let service = StubProfileService(profile: profile)
        let model = ProfileViewModel(service: service)
        let updated = UserProfile(id: "1", name: "Обновлённый", avatar: "", description: "", website: "", nfts: [], likes: [])
        model.accept(updated)
        guard case .loaded(let saved) = model.state else { return XCTFail("Expected loaded state") }
        XCTAssertEqual(saved.name, "Обновлённый")
    }
}

@MainActor
private final class RecordingProfileWebView: WKWebView {
    private(set) var requests: [URLRequest] = []

    override func load(_ request: URLRequest) -> WKNavigation? {
        requests.append(request)
        return nil
    }
}

private struct CapturedFormRequest: Decodable {
    let path: String
    let method: String
    let contentType: String
    let body: String
}

// Echo only the fields under test; no shared handler or real network traffic.
private final class FormRequestURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        do {
            guard let url = request.url,
                  let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) else {
                throw URLError(.badURL)
            }
            var body = request.httpBody ?? Data()
            if let stream = request.httpBodyStream {
                stream.open()
                defer { stream.close() }
                var buffer = [UInt8](repeating: 0, count: 1024)
                while true {
                    let count = stream.read(&buffer, maxLength: buffer.count)
                    if count < 0 { throw stream.streamError ?? URLError(.cannotDecodeRawData) }
                    if count == 0 { break }
                    body.append(contentsOf: buffer.prefix(count))
                }
            }
            let data = try JSONSerialization.data(withJSONObject: [
                "path": url.path,
                "method": request.httpMethod ?? "",
                "contentType": request.value(forHTTPHeaderField: "Content-Type") ?? "",
                "body": String(decoding: body, as: UTF8.self)
            ])
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }
}

private actor StubProfileService: ProfileService {
    var profile: UserProfile
    var failures: Int
    let delay: Duration
    private(set) var loadCount = 0
    private(set) var updateCount = 0

    init(profile: UserProfile, failures: Int = 0, delay: Duration = .zero) {
        self.profile = profile
        self.failures = failures
        self.delay = delay
    }

    func loadProfile() async throws -> UserProfile {
        loadCount += 1
        try await prepare()
        return profile
    }

    func updateProfile(fields: [String: String]) async throws -> UserProfile {
        updateCount += 1
        try await prepare()
        profile = UserProfile(id: profile.id, name: fields["name"] ?? profile.name,
                              avatar: fields["avatar"] ?? profile.avatar,
                              description: fields["description"] ?? profile.description,
                              website: fields["website"] ?? profile.website,
                              nfts: profile.nfts, likes: profile.likes)
        return profile
    }

    private func prepare() async throws {
        if delay != .zero { try await Task.sleep(for: delay) }
        if failures > 0 {
            failures -= 1
            throw URLError(.notConnectedToInternet)
        }
    }
}

private actor RecordingNetworkClient: NetworkClient {
    struct Request: Sendable {
        let path: String?
        let method: String
        let fields: [String: String]?
    }
    let profile: UserProfile
    private(set) var requests: [Request] = []

    init(profile: UserProfile) { self.profile = profile }

    func send(request: any NetworkRequest) async throws -> Data { Data() }

    func send<T: Decodable>(request: any NetworkRequest) async throws -> T {
        requests.append(Request(path: request.endpoint?.path, method: request.httpMethod.rawValue, fields: request.formParameters))
        guard let value = profile as? T else { throw NetworkClientError.parsingError }
        return value
    }
}
