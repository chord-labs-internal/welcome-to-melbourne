import Foundation

// MARK: - ContentLoading

/// Supplies the app's decoded content to features.
///
/// Features depend on this protocol rather than reaching for a bundle or
/// singleton directly, so tests can inject a fake loader with fixed content.
public protocol ContentLoading: Sendable {
    /// Load and decode the full application content.
    /// - Throws: ``ContentLoadingError`` if the resource is missing or malformed.
    func load() throws -> AppContent
}

// MARK: - Errors

public enum ContentLoadingError: Error, Equatable, Sendable {
    /// The `db.json` resource could not be located in the given bundle.
    case resourceNotFound(resource: String, ext: String)
    /// The resource was found but could not be read as `Data`.
    case unreadable(underlying: String)
    /// The JSON was found but failed to decode into ``AppContent``.
    case decodingFailed(underlying: String)
}

// MARK: - BundleContentLoader

/// Loads ``AppContent`` from a bundled JSON resource (default `db.json`
/// in `Bundle.main`). The bundle and resource name are configurable so
/// tests can point at their own copy of the data.
public struct BundleContentLoader: ContentLoading {
    private let bundle: Bundle
    private let resourceName: String
    private let resourceExtension: String

    public init(
        bundle: Bundle = .main,
        resourceName: String = "db",
        resourceExtension: String = "json"
    ) {
        self.bundle = bundle
        self.resourceName = resourceName
        self.resourceExtension = resourceExtension
    }

    public func load() throws -> AppContent {
        guard let url = bundle.url(forResource: resourceName, withExtension: resourceExtension) else {
            throw ContentLoadingError.resourceNotFound(resource: resourceName, ext: resourceExtension)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw ContentLoadingError.unreadable(underlying: String(describing: error))
        }

        return try Self.decode(from: data)
    }

    /// Decode ``AppContent`` from raw JSON `Data`.
    ///
    /// Exposed separately so tests can decode data they read from disk
    /// without depending on bundle-resource lookup.
    public static func decode(from data: Data) throws -> AppContent {
        do {
            return try JSONDecoder().decode(AppContent.self, from: data)
        } catch {
            throw ContentLoadingError.decodingFailed(underlying: String(describing: error))
        }
    }
}
