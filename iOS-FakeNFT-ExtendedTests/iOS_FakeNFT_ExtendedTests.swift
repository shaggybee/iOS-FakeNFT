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

@MainActor
final class ProfileNFTsTests: XCTestCase {
    private var profile: UserProfile {
        UserProfile(id: "1", name: "Антон", avatar: "", description: "", website: "",
                    nfts: ["1", "2", "3"], likes: ["2"])
    }

    private var items: [ProfileNFT] {
        [
            item("1", name: "Zebra", rating: 3, price: "1.78"),
            item("2", name: "Beta", rating: 5, price: "3.25"),
            item("3", name: "Alpha", rating: 4, price: "0.99")
        ]
    }

    private func item(_ id: String, name: String, rating: Int, price: String) -> ProfileNFT {
        ProfileNFT(nft: Nft(id: id, images: [], name: name, rating: rating,
                            price: Decimal(string: price) ?? 0, author: "author"),
                   author: NFTAuthor(id: "author", name: "John Doe"))
    }

    func testNFTAndAuthorDecodeAPIFieldsWithDecimalPrice() throws {
        let json = Data(#"{"id":"1","name":"April","images":["https://example.com/1.png"],"rating":5,"price":8.81,"author":"49","description":"Art"}"#.utf8)
        let nft = try JSONDecoder().decode(Nft.self, from: json)
        XCTAssertEqual(nft.price, Decimal(string: "8.81"))
        XCTAssertEqual(nft.rating, 5)
        XCTAssertEqual(nft.author, "49")
        XCTAssertEqual(nft.images.first?.host, "example.com")
        let authorJSON = Data(#"{"id":"49","name":"John Doe","rating":10,"nfts":[]}"#.utf8)
        XCTAssertEqual(try JSONDecoder().decode(NFTAuthor.self, from: authorJSON).name, "John Doe")
    }

    func testMalformedNFTPriceIsRejected() {
        let json = Data(#"{"id":"1","name":"A","images":[],"rating":5,"price":"invalid","author":"49"}"#.utf8)
        XCTAssertThrowsError(try JSONDecoder().decode(Nft.self, from: json))
    }

    func testServiceLoadsOnlyOwnedIDsAndDeduplicatesAuthors() async throws {
        let client = ProfileNFTNetworkClient(nfts: items.map(\.nft), authors: [items[0].author])
        let service = ProfileNFTsServiceImpl(
            nftService: NftServiceImpl(networkClient: client, storage: NftStorageImpl()), networkClient: client
        )
        let loaded = try await service.loadNFTs(ids: ["2", "1", "1"])
        XCTAssertEqual(Set(loaded.map(\.id)), Set(["1", "2"]))
        XCTAssertTrue(loaded.allSatisfy { $0.author.name == "John Doe" })
        let paths = await client.paths
        XCTAssertEqual(paths.filter { $0.hasPrefix("/api/v1/nft/") }.sorted(), ["/api/v1/nft/1", "/api/v1/nft/2"])
        XCTAssertEqual(paths.filter { $0.hasPrefix("/api/v1/users/") }, ["/api/v1/users/author"])
    }

    func testEmptyOwnedIDsDoNotSendRequests() async throws {
        let client = ProfileNFTNetworkClient(nfts: [], authors: [])
        let service = ProfileNFTsServiceImpl(
            nftService: NftServiceImpl(networkClient: client, storage: NftStorageImpl()), networkClient: client
        )
        let loaded = try await service.loadNFTs(ids: [])
        XCTAssertTrue(loaded.isEmpty)
        let paths = await client.paths
        XCTAssertTrue(paths.isEmpty)
    }

    func testMissingNFTFailsInsteadOfReturningPartialCollection() async {
        let client = ProfileNFTNetworkClient(nfts: [items[0].nft], authors: [items[0].author])
        let service = ProfileNFTsServiceImpl(
            nftService: NftServiceImpl(networkClient: client, storage: NftStorageImpl()), networkClient: client
        )
        do {
            _ = try await service.loadNFTs(ids: ["1", "missing"])
            XCTFail("A missing owned NFT must not be silently dropped")
        } catch { }
    }

    func testNFTServiceReusesSharedCache() async throws {
        let client = ProfileNFTNetworkClient(nfts: items.map(\.nft), authors: [])
        let service = NftServiceImpl(networkClient: client, storage: NftStorageImpl())
        let first = try await service.loadNft(id: "1")
        let second = try await service.loadNft(id: "1")
        XCTAssertEqual(first, second)
        let paths = await client.paths
        XCTAssertEqual(paths, ["/api/v1/nft/1"])
    }

    func testCollectionLimitsConcurrentRequests() async throws {
        let many = (0..<12).map { item(String($0), name: "NFT", rating: 5, price: "1") }
        let client = ProfileNFTNetworkClient(nfts: many.map(\.nft), authors: [many[0].author], delay: .milliseconds(10))
        let service = ProfileNFTsServiceImpl(
            nftService: NftServiceImpl(networkClient: client, storage: NftStorageImpl()), networkClient: client
        )
        let loaded = try await service.loadNFTs(ids: many.map(\.id))
        XCTAssertEqual(loaded.count, 12)
        let maximum = await client.maximumActive
        XCTAssertGreaterThan(maximum, 1)
        XCTAssertLessThanOrEqual(maximum, 4)
    }

    func testSortingUsesRatingDescendingPriceAscendingAndName() {
        XCTAssertEqual(ProfileNFTSort.rating.sorted(items).map(\.id), ["2", "3", "1"])
        XCTAssertEqual(ProfileNFTSort.price.sorted(items).map(\.id), ["3", "1", "2"])
        XCTAssertEqual(ProfileNFTSort.name.sorted(items).map(\.id), ["3", "2", "1"])
        let tied = [item("b", name: "Same", rating: 5, price: "1"), item("a", name: "Same", rating: 5, price: "1")]
        for option in ProfileNFTSort.allCases {
            XCTAssertEqual(option.sorted(tied).map(\.id), ["a", "b"])
        }
    }

    func testSortStoreDefaultsPersistsAndRejectsUnknownValue() {
        let suite = "ProfileNFTSortTests." + UUID().uuidString
        guard let defaults = UserDefaults(suiteName: suite) else { return XCTFail("Missing defaults suite") }
        defer { defaults.removePersistentDomain(forName: suite) }
        let first = ProfileNFTSortStore(defaults: defaults)
        XCTAssertEqual(first.selection, .rating)
        first.selection = .price
        XCTAssertEqual(ProfileNFTSortStore(defaults: defaults).selection, .price)
        defaults.set("obsolete", forKey: "Profile.myNFTs.sort")
        XCTAssertEqual(first.selection, .rating)
    }

    func testViewModelLoadsProfileIDsOnceAndSortsWithoutNetwork() async {
        let service = StubProfileNFTsService(items: items)
        let store = StubProfileSortStore()
        let model = ProfileNFTsViewModel(profile: profile, service: service, sortStore: store)
        await model.loadIfNeeded()
        await model.loadIfNeeded()
        XCTAssertEqual(model.items.map(\.id), ["2", "3", "1"])
        XCTAssertEqual(model.likedIDs, Set(["2"]))
        model.selectSort(.price)
        XCTAssertEqual(model.items.map(\.id), ["3", "1", "2"])
        XCTAssertEqual(store.selection, .price)
        let calls = await service.calls
        XCTAssertEqual(calls, [profile.nfts])
    }

    func testViewModelFailureCanRetry() async {
        let service = StubProfileNFTsService(items: items, failures: 1)
        let model = ProfileNFTsViewModel(profile: profile, service: service, sortStore: StubProfileSortStore())
        await model.load()
        guard case .error = model.state else { return XCTFail("Expected error") }
        XCTAssertTrue(model.showsError)
        await model.load()
        XCTAssertFalse(model.showsError)
        XCTAssertEqual(model.items.count, 3)
    }

    func testCancelledNFTLoadRestoresStateWithoutAlert() async {
        let service = StubProfileNFTsService(items: items, delay: .seconds(1))
        let model = ProfileNFTsViewModel(profile: profile, service: service, sortStore: StubProfileSortStore())
        let task = Task { await model.load() }
        await Task.yield()
        task.cancel()
        await task.value
        guard case .idle = model.state else { return XCTFail("Expected idle after cancellation") }
        XCTAssertFalse(model.showsError)
    }

    func testRepeatedNFTLoadDoesNotDuplicateRequest() async {
        let service = StubProfileNFTsService(items: items, delay: .milliseconds(20))
        let model = ProfileNFTsViewModel(profile: profile, service: service, sortStore: StubProfileSortStore())
        async let first: Void = model.load()
        async let second: Void = model.load()
        _ = await (first, second)
        let calls = await service.calls
        XCTAssertEqual(calls.count, 1)
        XCTAssertEqual(model.items.count, 3)
    }
}

@MainActor
private final class StubProfileSortStore: ProfileNFTSortStoring {
    var selection: ProfileNFTSort = .rating
}

private actor StubProfileNFTsService: ProfileNFTsService {
    let items: [ProfileNFT]
    var failures: Int
    let delay: Duration
    private(set) var calls: [[String]] = []

    init(items: [ProfileNFT], failures: Int = 0, delay: Duration = .zero) {
        self.items = items
        self.failures = failures
        self.delay = delay
    }

    func loadNFTs(ids: [String]) async throws -> [ProfileNFT] {
        calls.append(ids)
        if delay != .zero { try await Task.sleep(for: delay) }
        if failures > 0 {
            failures -= 1
            throw URLError(.notConnectedToInternet)
        }
        return items
    }
}

private actor ProfileNFTNetworkClient: NetworkClient {
    let nfts: [Nft]
    let authors: [NFTAuthor]
    let delay: Duration
    private(set) var paths: [String] = []
    private var active = 0
    private(set) var maximumActive = 0

    init(nfts: [Nft], authors: [NFTAuthor], delay: Duration = .zero) {
        self.nfts = nfts
        self.authors = authors
        self.delay = delay
    }

    func send(request: any NetworkRequest) async throws -> Data { throw NetworkClientError.parsingError }

    func send<Value: Decodable>(request: any NetworkRequest) async throws -> Value {
        let path = request.endpoint?.path ?? ""
        paths.append(path)
        active += 1
        maximumActive = max(maximumActive, active)
        defer { active -= 1 }
        if delay != .zero { try await Task.sleep(for: delay) }
        let id = request.endpoint?.lastPathComponent ?? ""
        if path.hasPrefix("/api/v1/nft/"), let nft = nfts.first(where: { $0.id == id }) as? Value { return nft }
        if path.hasPrefix("/api/v1/users/"), let author = authors.first(where: { $0.id == id }) as? Value { return author }
        throw NetworkClientError.httpStatusCode(404)
    }
}
