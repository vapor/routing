import Foundation
import HTTP

/// A representation of a `route` or endpoint in your application
/// It is made up of the basic components of a `route` and contains
/// optional metadata.
public final class Route {
    public let host: String
    public let components: [String]
    public let method: HTTP.Method
    public let metadata: [String: Any]
    
    public init(host: String, components: [String], method: HTTP.Method, metadata: [String: Any] = [:]) {
        self.host = host
        self.components = components
        self.method = method
        self.metadata = metadata
    }
}

extension Route{
    public var path: String {
        return "/" + components.joined(separator: "/")
    }
}
