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

public protocol DecodableRequestProtocol: RequestProtocol {

    associatedtype Result
    associatedtype ServerError: ServerErrorProtocol
    associatedtype ResponseBody

    static func deserializeError(from body: ResponseBody) throws -> ServerError

    static func deserializeResult(from body: ResponseBody) throws -> Result

    static func extractError<Response: ResponseProtocol>(
        from response: Response
    ) throws -> ServerError where Response.Body == ResponseBody

    static func extractResult<Response: ResponseProtocol>(
        from response: Response
    ) throws -> Result where Response.Body == ResponseBody
}

extension DecodableRequestProtocol {

    public static func extractError<Response: ResponseProtocol>(
        from response: Response
    ) throws -> ServerError where Response.Body == ResponseBody {
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

extension DecodableRequestProtocol where Result: Decodable {

    public static func extractResult<Response: ResponseProtocol>(
        from response: Response
    ) throws -> Result where Response.Body == ResponseBody {
        if response.statusCode.category == .success {
            return try deserializeResult(from: response.body)
        } else {
            throw try extractError(from: response)
        }
    }
}

extension DecodableRequestProtocol where Result == Void {
    public static func decodeResult<Response: ResponseProtocol>(
        from response: Response
    ) throws -> Void where Response.Body == ResponseBody {
        if response.statusCode.category == .success { return }
        throw try extractError(from: response)
    }
}

extension DecodableRequestProtocol where Result == ResponseBody {

    public static func decodeResult<Response: ResponseProtocol>(
        from response: Response
    ) throws -> ResponseBody where Response.Body == ResponseBody  {
        if response.statusCode.category == .success {
            return response.body
        } else {
            throw try extractError(from: response)
        }
    }
}
