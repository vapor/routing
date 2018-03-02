import Async
import Foundation
import Service

/// Capable of being used as a route parameter.
///
/// [Learn More →](https://docs.vapor.codes/3.0/routing/parameters/#creating-custom-parameters)
public protocol Parameter {
    /// the type of this parameter after it has been resolved.
    associatedtype ResolvedParameter

    // returns the found model for the resolved url parameter
    static func make(for parameter: String, using container: Container) throws -> ResolvedParameter
}

extension String: Parameter {
    /// Reads the raw parameter
    public static func make(for parameter: String, using container: Container) throws -> String {
        return parameter
    }
}

extension Int: Parameter {
    /// Attempts to read the parameter into a `Int`
    public static func make(for parameter: String, using container: Container) throws -> Int {
        guard let number = Int(parameter) else {
            throw RoutingError(identifier: "parameterNotAnInt", reason: "The parameter was not convertible to an Int", source: .capture())
        }

        return number
    }
}

extension Double: Parameter {
    /// Attempts to read the parameter into a `Double`
    public static func make(for parameter: String, using container: Container) throws -> Double {
        guard let number = Double(parameter) else {
            throw RoutingError(identifier: "parameterNotAnInt", reason: "The parameter was not convertible to a Double", source: .capture())
        }

        return number
    }
}

extension Int8: Parameter {
    /// Attempts to read the parameter into a `Int8`
    public static func make(for parameter: String, using container: Container) throws -> Int8 {
        guard let number = Int8(parameter) else {
            throw RoutingError(identifier: "parameterNotAnInt", reason: "The parameter was not convertible to an Int8", source: .capture())
        }

        return number
    }
}

extension Int16: Parameter {
    /// Attempts to read the parameter into a `Int16`
    public static func make(for parameter: String, using container: Container) throws -> Int16 {
        guard let number = Int16(parameter) else {
            throw RoutingError(identifier: "parameterNotAnInt", reason: "The parameter was not convertible to an Int16", source: .capture())
        }

        return number
    }
}

extension Int32: Parameter {
    /// Attempts to read the parameter into a `Int32`
    public static func make(for parameter: String, using container: Container) throws -> Int32 {
        guard let number = Int32(parameter) else {
            throw RoutingError(identifier: "parameterNotAnInt", reason: "The parameter was not convertible to an Int32", source: .capture())
        }

        return number
    }
}

extension Int64: Parameter {
    /// Attempts to read the parameter into a `Int64`
    public static func make(for parameter: String, using container: Container) throws -> Int64 {
        guard let number = Int64(parameter) else {
            throw RoutingError(identifier: "parameterNotAnInt", reason: "The parameter was not convertible to an Int64", source: .capture())
        }

        return number
    }
}

extension UInt8: Parameter {
    /// Attempts to read the parameter into a `UInt8`
    public static func make(for parameter: String, using container: Container) throws -> UInt8 {
        guard let number = UInt8(parameter) else {
            throw RoutingError(identifier: "parameterNotAnInt", reason: "The parameter was not convertible to an UInt8", source: .capture())
        }

        return number
    }
}

extension UInt16: Parameter {
    /// Attempts to read the parameter into a `UInt16`
    public static func make(for parameter: String, using container: Container) throws -> UInt16 {
        guard let number = UInt16(parameter) else {
            throw RoutingError(identifier: "parameterNotAnInt", reason: "The parameter was not convertible to an UInt16", source: .capture())
        }

        return number
    }
}

extension UInt32: Parameter {
    /// Attempts to read the parameter into a `UInt32`
    public static func make(for parameter: String, using container: Container) throws -> UInt32 {
        guard let number = UInt32(parameter) else {
            throw RoutingError(identifier: "parameterNotAnInt", reason: "The parameter was not convertible to an UInt32", source: .capture())
        }

        return number
    }
}

extension UInt64: Parameter {
    /// Attempts to read the parameter into a `UInt64`
    public static func make(for parameter: String, using container: Container) throws -> UInt64 {
        guard let number = UInt64(parameter) else {
            throw RoutingError(identifier: "parameterNotAnInt", reason: "The parameter was not convertible to an UInt64", source: .capture())
        }

        return number
    }
}

extension UUID: Parameter {
    /// Attempts to read the parameter into a `UUID`
    public static func make(for parameter: String, using container: Container) throws -> UUID {
        guard let uuid = UUID(uuidString: parameter) else {
            throw RoutingError(identifier: "parameterNotAUUID", reason: "The parameter was not convertible to a UUID", source: .capture())
        }

        return uuid
    }
}

