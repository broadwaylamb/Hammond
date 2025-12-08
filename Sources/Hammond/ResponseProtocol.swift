//
//  ResponseProtocol.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 12/04/2018.
//

public protocol ResponseProtocol<Body> {

    /// The type of the response's body. Usually implemented as an array of bytes,
    /// or `Foundation.Data`.
    associatedtype Body

    /// The three-digit status code of the performed HTTP request.
    var statusCode: HTTPStatusCode { get }

    /// The body blob of the response.
    var body: Body { get }
}
