//
//  RequestProtocol.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 12/04/2018.
//

import Foundation

public protocol RequestProtocol {

    var path: String { get }

    static var successStatusCode: HTTPStatusCode { get }
}

extension RequestProtocol {
    public static var successStatusCode: HTTPStatusCode { return 200 }
}

public protocol DecodableRequestProtocol: RequestProtocol {

    associatedtype Result
    associatedtype ServerError: ServerErrorProtocol

    static func deserializeResult<T: Decodable>(from data: Data) throws -> T

    static func decodeError<Response: ResponseProtocol>(
        from response: Response
    ) throws -> ServerError

    static func decodeResult<Response: ResponseProtocol>(
        from response: Response
    ) throws -> Result
}

extension DecodableRequestProtocol {

    public static func decodeError<Response: ResponseProtocol>(
        from response: Response
    ) throws -> ServerError {

        do {
            return try deserializeResult(from: response.data)
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

extension DecodableRequestProtocol where Result: Decodable {

    public static func decodeResult<Response: ResponseProtocol>(
        from response: Response
    ) throws -> Result {

        if response.statusCode == successStatusCode {
            return try deserializeResult(from: response.data)
        } else {
            throw try decodeError(from: response)
        }
    }
}

extension DecodableRequestProtocol where Result == Void {

    public static func decodeResult<Response: ResponseProtocol>(
        from response: Response
    ) throws -> Void {

        if response.statusCode == successStatusCode { return }

        throw try decodeError(from: response)
    }
}

extension DecodableRequestProtocol where Result == Data {

    public static func decodeResult<Response: ResponseProtocol>(
        from response: Response
    ) throws -> Data {

        if response.statusCode == successStatusCode {
            return response.data
        } else {
            throw try decodeError(from: response)
        }
    }
}
