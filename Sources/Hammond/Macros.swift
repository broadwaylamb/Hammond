//
//  Macros.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 29/06/2025.
//

@attached(extension, conformances: RequestProtocol, names: named(method), named(path), named(queryItems))
public macro HTTPRequest(_ name: String, _ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(queryItems))
public macro HTTPRequest(_ name: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(path), named(queryItems))
public macro OPTIONS(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(queryItems))
public macro OPTIONS() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(path), named(queryItems))
public macro GET(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(queryItems))
public macro GET() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(path), named(queryItems))
public macro HEAD(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(queryItems))
public macro HEAD() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(path), named(queryItems))
public macro POST(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(queryItems))
public macro POST() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(path), named(queryItems))
public macro PUT(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(queryItems))
public macro PUT() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(path), named(queryItems))
public macro PATCH(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(queryItems))
public macro PATCH() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(path), named(queryItems))
public macro DELETE(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(queryItems))
public macro DELETE() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(path), named(queryItems))
public macro TRACE(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(queryItems))
public macro TRACE() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(path), named(queryItems))
public macro CONNECT(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(extension, conformances: RequestProtocol, names: named(method), named(path), named(queryItems))
public macro CONNECT() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

@attached(
    extension,
    conformances: EncodableRequestProtocol,
    names: named(encodableQuery),
    named(encodableBody)
)
public macro EncodableRequest() =
    #externalMacro(module: "HammondMacros", type: "EncodableRequestMacro")

@attached(peer)
public macro Query(key: String) = #externalMacro(
    module: "HammondMacros",
    type: "MarkerMacro"
)

@attached(peer)
public macro Query() = #externalMacro(
    module: "HammondMacros",
    type: "MarkerMacro"
)

@attached(
    extension,
    conformances:
        RawRepresentable,
        Codable,
        Hashable,
        Equatable,
        CustomDebugStringConvertible,
    names: named(debugDescription)
)
@attached(member, names: named(rawValue), named(`init`))
public macro Newtype<RawValue: Codable & Hashable & Equatable>() =
    #externalMacro(module: "HammondMacros", type: "NewtypeMacro")
