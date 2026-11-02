import Foundation

enum StoreChoice: String, Codable, CaseIterable, Identifiable {
    case instacartAldi
    case aldi
    case walmart
    case target
    case amazonFresh

    var id: String { rawValue }

    var name: String {
        switch self {
        case .instacartAldi: return "Aldi via Instacart"
        case .aldi: return "Aldi"
        case .walmart: return "Walmart"
        case .target: return "Target"
        case .amazonFresh: return "Amazon Fresh"
        }
    }

    var shortName: String {
        switch self {
        case .instacartAldi: return "Instacart"
        case .aldi: return "Aldi"
        case .walmart: return "Walmart"
        case .target: return "Target"
        case .amazonFresh: return "Amazon"
        }
    }

    /// A search-results URL for `term` at this store. Opens in Safari, or the
    /// store's app if it claims the link via universal links.
    func searchURL(for term: String) -> URL? {
        var components: URLComponents
        switch self {
        case .instacartAldi:
            components = URLComponents(string: "https://www.instacart.com/store/aldi/s")!
            components.queryItems = [URLQueryItem(name: "k", value: term)]
        case .aldi:
            components = URLComponents(string: "https://www.aldi.us/results")!
            components.queryItems = [URLQueryItem(name: "q", value: term)]
        case .walmart:
            components = URLComponents(string: "https://www.walmart.com/search")!
            components.queryItems = [URLQueryItem(name: "q", value: term)]
        case .target:
            components = URLComponents(string: "https://www.target.com/s")!
            components.queryItems = [URLQueryItem(name: "searchTerm", value: term)]
        case .amazonFresh:
            components = URLComponents(string: "https://www.amazon.com/s")!
            components.queryItems = [
                URLQueryItem(name: "k", value: term),
                URLQueryItem(name: "i", value: "amazonfresh"),
            ]
        }
        return components.url
    }
}
