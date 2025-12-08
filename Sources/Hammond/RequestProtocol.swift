//
//  RequestProtocol.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 12/04/2018.
//

public protocol RequestProtocol {
    var path: String { get }
    static var method: HTTPMethod { get }
}

public protocol EncodableRequestProtocol {
    associatedtype EncodableQuery: Encodable = NeverCodable
    associatedtype EncodableBody: Encodable = NeverCodable

    var encodableQuery: EncodableQuery? { get }
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

public protocol DecodableRequestProtocol: RequestProtocol {
    associatedtype Result
    associatedtype ServerError: ServerErrorProtocol
    associatedtype ResponseBody

    func deserializeError(from body: ResponseBody) throws -> ServerError

    func deserializeResult(from body: ResponseBody) throws -> Result

    func extractError(
        from response: some ResponseProtocol<ResponseBody>
    ) throws -> ServerError

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
