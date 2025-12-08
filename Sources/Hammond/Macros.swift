//
//  Macros.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 29/06/2025.
//

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @HTTPRequest("GET", "/api/getUser/{userID}")
/// struct GetUser {
///   var userID: Int
/// }
/// ```
///
/// - parameter name: The HTTP method to use for performing this request.
/// - parameter path: The path part of this request.
///     The path may mention the request's properties using the `{propertyName}` syntax.
@attached(extension, conformances: RequestProtocol, names: named(method), named(path))
public macro HTTPRequest(_ name: String, _ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @HTTPRequest("/api/getUser/{userID}")
/// struct GetUser {
///   var userID: Int
///   static var method: HTTPMethod { .get }
/// }
/// ```
///
/// - parameter path: The path part of this request.
///     The path may mention the request's properties using the `{propertyName}` syntax.
@attached(extension, conformances: RequestProtocol, names: named(method))
public macro HTTPRequest(_ name: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @OPTIONS("/api/getUser/{userID}")
/// struct GetUser {
///   var userID: Int
/// }
/// ```
///
/// - parameter path: The path part of this request.
///     The path may mention the request's properties using the `{propertyName}` syntax.
@attached(extension, conformances: RequestProtocol, names: named(method), named(path))
public macro OPTIONS(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @OPTIONS
/// struct GetUser {
///   var userID: Int
///   var path: String { "/api/getUser/\(userID)" }
/// }
/// ```
@attached(extension, conformances: RequestProtocol, names: named(method))
public macro OPTIONS() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @GET("/api/getUser/{userID}")
/// struct GetUser {
///   var userID: Int
/// }
/// ```
///
/// - parameter path: The path part of this request.
///     The path may mention the request's properties using the `{propertyName}` syntax.
@attached(extension, conformances: RequestProtocol, names: named(method), named(path))
public macro GET(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @GET
/// struct GetUser {
///   var userID: Int
///   var path: String { "/api/getUser/\(userID)" }
/// }
/// ```
@attached(extension, conformances: RequestProtocol, names: named(method))
public macro GET() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @HEAD("/api/getUser/{userID}")
/// struct GetUser {
///   var userID: Int
/// }
/// ```
///
/// - parameter path: The path part of this request.
///     The path may mention the request's properties using the `{propertyName}` syntax.
@attached(extension, conformances: RequestProtocol, names: named(method), named(path))
public macro HEAD(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @HEAD
/// struct GetUser {
///   var userID: Int
///   var path: String { "/api/getUser/\(userID)" }
/// }
@attached(extension, conformances: RequestProtocol, names: named(method))
public macro HEAD() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @POST("/api/createUser/{name}")
/// struct CreateUser {
///   var name: String
/// }
/// ```
///
/// - parameter path: The path part of this request.
///     The path may mention the request's properties using the `{propertyName}` syntax.
@attached(extension, conformances: RequestProtocol, names: named(method), named(path))
public macro POST(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @POST
/// struct CreateUser {
///   var name: String
///   var path: String { "/api/createUser/\(name)" }
/// }
/// ```
@attached(extension, conformances: RequestProtocol, names: named(method))
public macro POST() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @PUT("/api/createUser/{name}")
/// struct CreateUser {
///   var name: String
/// }
/// ```
///
/// - parameter path: The path part of this request.
///     The path may mention the request's properties using the `{propertyName}` syntax.
@attached(extension, conformances: RequestProtocol, names: named(method), named(path))
public macro PUT(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @PUT
/// struct CreateUser {
///   var name: String
///   var path: String { "/api/createUser/\(name)" }
/// }
/// ```
@attached(extension, conformances: RequestProtocol, names: named(method))
public macro PUT() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @PATCH("/api/renameUser/{userID}")
/// struct RenameUser {
///   var userID: Int
/// }
/// ```
///
/// - parameter path: The path part of this request.
///     The path may mention the request's properties using the `{propertyName}` syntax.
@attached(extension, conformances: RequestProtocol, names: named(method), named(path))
public macro PATCH(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @PATCH
/// struct RenameUser {
///   var userID: Int
///   var path: String { "/api/renameUser/\(userID)" }
/// }
/// ```
@attached(extension, conformances: RequestProtocol, names: named(method))
public macro PATCH() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @DELETE("/api/deleteUser/{userID}")
/// struct DeleteUser {
///   var userID: Int
/// }
/// ```
///
/// - parameter path: The path part of this request.
///     The path may mention the request's properties using the `{propertyName}` syntax.
@attached(extension, conformances: RequestProtocol, names: named(method), named(path))
public macro DELETE(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @DELETE
/// struct DeleteUser {
///   var userID: Int
///   var path: String { "/api/deleteUser/\(userID)" }
/// }
/// ```
@attached(extension, conformances: RequestProtocol, names: named(method))
public macro DELETE() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @TRACE("/api/resource/{resourceID}")
/// struct TraceResource {
///   var resourceID: Int
/// }
/// ```
///
/// - parameter path: The path part of this request.
///     The path may mention the request's properties using the `{propertyName}` syntax.
@attached(extension, conformances: RequestProtocol, names: named(method), named(path))
public macro TRACE(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @TRACE
/// struct TraceResource {
///   var resourceID: Int
///   var path: String { "/api/resource/\(resourceID)" }
/// }
/// ```
@attached(extension, conformances: RequestProtocol, names: named(method))
public macro TRACE() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @CONNECT("/api/resource/{resourceID}")
/// struct ConnectWithResource {
///   var resourceID: Int
/// }
/// ```
///
/// - parameter path: The path part of this request.
///     The path may mention the request's properties using the `{propertyName}` syntax.
@attached(extension, conformances: RequestProtocol, names: named(method), named(path))
public macro CONNECT(_ path: String) =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``RequestProtocol``.
///
/// Example:
/// ```swift
/// @CONNECT
/// struct ConnectWithResource {
///   var resourceID: Int
///   var path: String { "/api/resource/\(resourceID)" }
/// }
/// ```
@attached(extension, conformances: RequestProtocol, names: named(method), named(path))
public macro CONNECT() =
    #externalMacro(module: "HammondMacros", type: "RequestMacro")

/// Provides an implementation of ``EncodableRequestProtocol``.
///
/// Stored properties annoated with the ``Query()`` or ``Query(key:)`` macro are
/// used to implement ``EncodableRequestProtocol/encodableQuery``, and the rest
/// stored properties are used to implement ``EncodableRequestProtocol/encodableBody``.
@attached(
    extension,
    conformances: EncodableRequestProtocol,
    names: named(encodableQuery),
    named(encodableBody)
)
public macro EncodableRequest() =
    #externalMacro(module: "HammondMacros", type: "EncodableRequestMacro")

/// Indicates that this stored property should be used to build
/// ``EncodableRequestProtocol/encodableQuery`` when the containing type is
/// annotated with ``EncodableRequest()``.
///
/// - parameter key: The custom coding key to use in
///     for encoding this property in ``EncodableRequestProtocol/encodableQuery``.
@attached(peer)
public macro Query(key: String) = #externalMacro(
    module: "HammondMacros",
    type: "MarkerMacro"
)

/// Indicates that this stored property should be used to build
/// ``EncodableRequestProtocol/encodableQuery`` when the containing type is
/// annotated with ``EncodableRequest()``.
@attached(peer)
public macro Query() = #externalMacro(
    module: "HammondMacros",
    type: "MarkerMacro"
)

/// Use this macro to avoid boilerplate when creating strongly typed identifiers.
///
/// For example, if in your application you work with numeric user identifiers,
/// instead of using raw `Int`, create a new type `UserID` with this macro:
///
/// ```swift
/// @Newtype<Int>
/// struct UserID {}
/// ```
///
/// This type will automatically conform to `RawRepresentable`, `Codable`, `Equatable`m
/// `Hashable`, `CustomStringConvertible` and `CustomDebugStringConvertible`,
/// so you don't have to manually implement these conformances.
@attached(
    extension,
    conformances:
        RawRepresentable,
        Codable,
        Hashable,
        Equatable,
        CustomStringConvertible,
        CustomDebugStringConvertible,
    names: named(debugDescription), named(description)
)
@attached(member, names: named(rawValue), named(init(rawValue:)))
public macro Newtype<RawValue: Codable & Hashable & Equatable>() =
    #externalMacro(module: "HammondMacros", type: "NewtypeMacro")
