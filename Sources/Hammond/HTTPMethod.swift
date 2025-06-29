//
//  HTTPMethod.swift
//  
//
//  Created by Sergej Jaskiewicz on 15.07.2019.
//

public struct HTTPMethod: RawRepresentable, Hashable, Codable, Sendable {

    public var rawValue: String

    @inlinable
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension HTTPMethod: CustomStringConvertible {
    public var description: String { return rawValue }
}

extension HTTPMethod {
    public static let options = HTTPMethod(rawValue: "OPTIONS")
    public static let get     = HTTPMethod(rawValue: "GET")
    public static let head    = HTTPMethod(rawValue: "HEAD")
    public static let post    = HTTPMethod(rawValue: "POST")
    public static let put     = HTTPMethod(rawValue: "PUT")
    public static let patch   = HTTPMethod(rawValue: "PATCH")
    public static let delete  = HTTPMethod(rawValue: "DELETE")
    public static let trace   = HTTPMethod(rawValue: "TRACE")
    public static let connect = HTTPMethod(rawValue: "CONNECT")
}
