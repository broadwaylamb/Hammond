//
//  ServerErrorProtocol.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 15/04/2018.
//

public protocol ServerErrorProtocol: Error {
    /// Construct a default error for the passed status code.
    static func defaultError(for statusCode: HTTPStatusCode) -> Self
}
