//
//  HTTPStatusCode.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 12/04/2018.
//

public struct HTTPStatusCode: RawRepresentable, Hashable {

    public var rawValue: Int

#if swift(>=5)
    @inlinable
#endif
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public enum Category {
        case informational
        case success
        case redirection
        case clientError
        case serverError
        case other
    }

#if swift(>=5)
    @inlinable
#endif
    public var category: Category {
        switch rawValue {
        case 100 ..< 200: return .informational
        case 200 ..< 300: return .success
        case 300 ..< 400: return .redirection
        case 400 ..< 500: return .clientError
        case 500 ..< 600: return .serverError
        default:          return .other
        }
    }
}

extension HTTPStatusCode: ExpressibleByIntegerLiteral {

#if swift(>=5)
    @inlinable
#endif
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: Int(value))
    }
}

extension HTTPStatusCode: CustomStringConvertible {

#if swift(>=5)
    @inlinable
#endif
    public var description: String { return String(rawValue) }
}
