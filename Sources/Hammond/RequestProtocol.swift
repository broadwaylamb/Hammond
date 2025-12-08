//
//  RequestProtocol.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 12/04/2018.
//

/// Represents a network request.
///
/// You usually don't want to conform to this protocol; instead, conform to
/// ``DecodableRequestProtocol`` and/or ``EncodableRequestProtocol``, which both
/// inherit from ``RequestProtocol``.
public protocol RequestProtocol {
    var path: String { get }
    static var method: HTTPMethod { get }
}

/// Conform to this protocol if you want to provide a way to encode the request's
/// data into its query and body.
/// Use `URLEncodedFormEncoder` from the `HammondEncoders` module to convert
/// ``encodableQuery`` into a string or a list of query items.
///
/// You can use the ``EncodableRequest()`` macro to generate the conformance to this
/// protocol. Stored properties marked with ``Query()`` will be used to generate
/// the implementation of ``encodableQuery``, and the rest properties will
/// constitute ``encodableBody``.
public protocol EncodableRequestProtocol: RequestProtocol {
    associatedtype EncodableQuery: Encodable = NeverCodable
    associatedtype EncodableBody: Encodable = NeverCodable

    /// The query part of the request that should be encoded via `URLEncodedFormEncoder`.
    ///
    /// The default implementation returns `nil`.
    var encodableQuery: EncodableQuery? { get }

    /// The body of the request.
    ///
    /// You can use any encoder of your choice to transform this value to the actual
    /// request body blob.
    ///
    /// The default implementation returns `nil`.
    var encodableBody: EncodableBody? { get }
}

extension EncodableRequestProtocol {
    public var encodableQuery: EncodableQuery? {
        nil
    }

    public var encodableBody: EncodableBody? {
        nil
    }
}

/// Conform to this protocol if you want to associate a request with its response type.
///
/// The protocol requirements provide customization points for converting the response
/// body blobs ``ResponseBody`` to structured data ``Result``.
public protocol DecodableRequestProtocol: RequestProtocol {

    /// The decoded result of the request.
    associatedtype Result

    /// The error that this request may return instead of ``Result``.
    associatedtype ServerError: ServerErrorProtocol

    /// Something that you receive from the network and want to convert to ``Result``.
    associatedtype ResponseBody

    /// Deserializes ``ServerError`` from ``ResponseBody``.
    func deserializeError(from body: ResponseBody) throws -> ServerError

    /// Deserializes ``Result`` from ``ResponseBody``.
    func deserializeResult(from body: ResponseBody) throws -> Result

    /// Given a network response, tries to extract ``ServerError`` from it.
    ///
    /// The default implementation tries to call ``deserializeError(from:)``
    /// with the response's ``ResponseProtocol/body``, and if it doesn't succeed,
    /// returns ``ServerErrorProtocol/defaultError(for:)`` for the response's
    /// ``ResponseProtocol/statusCode``.
    func extractError(
        from response: some ResponseProtocol<ResponseBody>
    ) throws -> ServerError

    /// Given a network response, tries to extract the request's ``Result`` from it.
    ///
    /// The default implementation calls ``deserializeResult(from:)`` if
    /// ``ResponseProtocol/statusCode`` is successful, and ``extractError(from:)``
    /// if it isn't.
    func extractResult(
        from response: some ResponseProtocol<ResponseBody>
    ) throws -> Result
}

extension DecodableRequestProtocol {
    public func extractError(
        from response: some ResponseProtocol<ResponseBody>
    ) throws -> ServerError {
        do {
            return try deserializeError(from: response.body)
        } catch {
            let status = response.statusCode
            if status.category != .success {
                return .defaultError(for: status)
            } else {
                throw error
            }
        }
    }
}

extension DecodableRequestProtocol {
    public func extractResult(
        from response: some ResponseProtocol<ResponseBody>
    ) throws -> Result {
        if response.statusCode.category == .success {
            return try deserializeResult(from: response.body)
        } else {
            throw try extractError(from: response)
        }
    }
}

extension DecodableRequestProtocol where Result == Void {
    public func deserializeResult(from body: ResponseBody) throws -> Void {}
}

extension DecodableRequestProtocol where Result == ResponseBody {
    public func extractResult(
        from response: some ResponseProtocol<ResponseBody>
    ) throws -> ResponseBody  {
        if response.statusCode.category == .success {
            return response.body
        } else {
            throw try extractError(from: response)
        }
    }
}
