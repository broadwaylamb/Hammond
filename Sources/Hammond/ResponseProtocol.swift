//
//  ResponseProtocol.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 12/04/2018.
//

public protocol ResponseProtocol {

    associatedtype Body

    var statusCode: HTTPStatusCode { get }

    var body: Body { get }
}
