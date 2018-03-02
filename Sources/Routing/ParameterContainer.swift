import Async
import Foundation
import Service

/// A bag for holding parameters resolved during router
///
/// [Learn More →](https://docs.vapor.codes/3.0/routing/parameters/)
public protocol ParameterContainer: class {
    /// An array of parameters
    typealias Parameters = [ParameterValue]

    /// The parameters, not yet resolved
    /// so that the `.next()` method can throw any errors.
    var parameters: Parameters { get set }
}

/// MARK: Next

extension Container where Self: ParameterContainer {
    /// Grabs the next parameter from the parameter bag.
    ///
    /// Note: the parameters _must_ be fetched in the order they
    /// appear in the path.
    ///
    /// For example GET /posts/:post_id/comments/:comment_id
    /// must be fetched in this order:
    ///
    ///     let post = try parameters.next(Post.self)
    ///     let comment = try parameters.next(Comment.self)
    ///
    public func parameter<P>(_ parameter: P.Type = P.self) throws -> P.ResolvedParameter
        where P: Parameter
    {
        return try self.parameter(P.self, using: self)
    }

    /// Infer requested type where the resolved parameter is the parameter type.
    public func parameter<P>() throws -> P
        where P: Parameter, P.ResolvedParameter == P
    {
        return try self.parameter(P.self)
    }
}

extension ParameterContainer {
    /// Grabs the next parameter from the parameter bag.
    ///
    /// Note: the parameters _must_ be fetched in the order they
    /// appear in the path.
    ///
    /// For example GET /posts/:post_id/comments/:comment_id
    /// must be fetched in this order:
    ///
    ///     let post = try parameters.next(Post.self)
    ///     let comment = try parameters.next(Comment.self)
    ///
    public func parameter<P>(_ parameter: P.Type = P.self, using container: Container) throws -> P.ResolvedParameter
        where P: Parameter
    {
        guard parameters.count > 0 else {
            throw RoutingError(identifier: "insufficientParameters", reason: "Insufficient parameters", source: .capture())
        }

        let current = parameters[0]

        guard let string = String(bytes: current.value, encoding: .utf8) else {
            throw RoutingError(
                identifier: "convertString",
                reason: "Could not convert the parameter value to a UTF-8 string.",
                source: .capture()
            )
        }

        let item = try P.make(for: string, using: container)
        parameters = Array(parameters.dropFirst())
        return item
    }
}
