import Foundation

/// Thin network client for the WallHaven v1 API.
/// Responsible only for HTTP: URL construction, decoding, and error mapping.
actor WallHavenAPI {
    private let session: URLSession
    private let apiKey: String?

    private static let base = URL(string: "https://wallhaven.cc/api/v1")!

    init(apiKey: String? = nil, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }

    func search(query: WHSearchQuery) async throws -> WHSearchResponse {
        let request = try buildRequest(path: "/search", queryItems: query.queryItems(apiKey: apiKey))
        return try await perform(request)
    }

    func downloadData(from url: URL) async throws -> Data {
        let request = URLRequest(url: url)
        let (data, response) = try await session.data(for: request)
        try validate(response)
        return data
    }
}

// MARK: - Request building

private extension WallHavenAPI {
    func buildRequest(path: String, queryItems: [URLQueryItem]) throws -> URLRequest {
        var components = URLComponents(url: Self.base.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        components.queryItems = queryItems.filter { $0.value != nil && !($0.value?.isEmpty ?? true) }
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        return URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
    }

    func perform<T: Decodable & Sendable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        try validate(response)
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }

    func validate(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        switch http.statusCode {
        case 200...299: return
        case 401:       throw WallHavenError.invalidAPIKey
        case 429:       throw WallHavenError.rateLimited
        default:        throw WallHavenError.httpError(statusCode: http.statusCode)
        }
    }
}

// MARK: - Search query

struct WHSearchQuery: Sendable {
    var query: String = ""
    var categories: Categories = .all
    var purity: Purity = .sfw
    var atleast: String = "1920x1080"
    var ratios: String = "16x9"
    var sorting: Sorting = .random
    var page: Int = 1

    struct Categories: OptionSet, Sendable {
        let rawValue: Int
        static let general = Categories(rawValue: 1 << 2)
        static let anime   = Categories(rawValue: 1 << 1)
        static let people  = Categories(rawValue: 1 << 0)
        static let all: Categories = [.general, .anime, .people]

        var apiString: String {
            let g = contains(.general) ? "1" : "0"
            let a = contains(.anime)   ? "1" : "0"
            let p = contains(.people)  ? "1" : "0"
            return g + a + p
        }
    }

    struct Purity: OptionSet, Sendable {
        let rawValue: Int
        static let sfw     = Purity(rawValue: 1 << 2)
        static let sketchy = Purity(rawValue: 1 << 1)
        static let nsfw    = Purity(rawValue: 1 << 0)

        var apiString: String {
            let s = contains(.sfw)     ? "1" : "0"
            let k = contains(.sketchy) ? "1" : "0"
            let n = contains(.nsfw)    ? "1" : "0"
            return s + k + n
        }
    }

    enum Sorting: String, Sendable {
        case dateAdded = "date_added"
        case relevance
        case random
        case views
        case favorites
        case toplist
    }

    func queryItems(apiKey: String?) -> [URLQueryItem] {
        var items: [URLQueryItem] = [
            .init(name: "q",          value: query),
            .init(name: "categories", value: categories.apiString),
            .init(name: "purity",     value: purity.apiString),
            .init(name: "atleast",    value: atleast),
            .init(name: "ratios",     value: ratios),
            .init(name: "sorting",    value: sorting.rawValue),
            .init(name: "page",       value: String(page)),
        ]
        if let key = apiKey {
            items.append(.init(name: "apikey", value: key))
        }
        return items
    }
}
