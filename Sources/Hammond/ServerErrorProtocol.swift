//
//  ServerErrorProtocol.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 15/04/2018.
//

public protocol ServerErrorProtocol: Error, Decodable {
    static func defaultError(for statusCode: HTTPStatusCode) -> Self
}
