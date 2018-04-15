//
//  ResponseProtocol.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 12/04/2018.
//

import struct Foundation.Data

/// Extend the response type of the networking library you use to conform
/// to this protocol. Then you will be able to pass instances of that type
/// to the `DecodableRequestProtocol.decodeResult(from:)` method which will
/// take care of decoding JSON from the response.
///
/// If your conforming type has some of the required properties of wrong type,
/// you always can wrap it in a transparent struct.
///
/// For example:
///
/// ```swift
/// import Vapor
///
/// extension Vapor.Response: ResponseProtocol {
///
///     var statusCode: HTTPStatusCode {
///         return HTTPStatusCode(rawValue: status.statusCode)
///     }
///
///     var data: Data {
///         return body.bytes.map(Data.init) ?? Data()
///     }
/// }
/// ```
///
/// ```swift
/// import Moya
///
/// /// Moya.Request.statusCode property is of type Int,
/// /// so we need this wrapper.
/// struct MoyaResponseWrapper {
///     let moyaResponse: Moya.Response
/// }
///
/// extension MoyaResponseWrapper: ResponseProtocol {
///
///     var statusCode: HTTPStatusCode {
///         return HTTPStatusCode(rawValue: moyaResponse.statusCode)
///     }
///
///     var data: Data {
///         return moyaResponse.data
///     }
/// }
/// ```
public protocol ResponseProtocol {

    var statusCode: HTTPStatusCode { get }

    var data: Data { get }
}
