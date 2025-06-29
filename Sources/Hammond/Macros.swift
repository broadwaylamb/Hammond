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
