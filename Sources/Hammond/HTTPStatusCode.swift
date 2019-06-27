//
//  HTTPStatusCode.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 12/04/2018.
//

public struct HTTPStatusCode: RawRepresentable, Hashable {

    public var rawValue: Int

    @inlinable
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public enum Category {
        case informational
        case success
        case redirection
        case clientError
        case serverError
        case other
    }

    @inlinable
    public var category: Category {
        switch rawValue {
        case 100 ..< 200: return .informational
        case 200 ..< 300: return .success
        case 300 ..< 400: return .redirection
        case 400 ..< 500: return .clientError
        case 500 ..< 600: return .serverError
        default:          return .other
        }
    }
}

extension HTTPStatusCode: ExpressibleByIntegerLiteral {

    @inlinable
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: Int(value))
    }
}

extension HTTPStatusCode: CustomStringConvertible {

    @inlinable
    public var description: String { return String(rawValue) }
}

extension HTTPStatusCode {

    public static let `continue` = HTTPStatusCode(rawValue: 100)

    public static let switchingProtocols = HTTPStatusCode(rawValue: 101)

    public static let processing = HTTPStatusCode(rawValue: 102)

    public static let earlyHints = HTTPStatusCode(rawValue: 103)

    public static let ok = HTTPStatusCode(rawValue: 200)

    public static let created = HTTPStatusCode(rawValue: 201)

    public static let accepted = HTTPStatusCode(rawValue: 202)

    public static let nonAuthoritativeInformation = HTTPStatusCode(rawValue: 203)

    public static let noContent = HTTPStatusCode(rawValue: 204)

    public static let resetContent = HTTPStatusCode(rawValue: 205)

    public static let partialContent = HTTPStatusCode(rawValue: 206)

    public static let multiStatus = HTTPStatusCode(rawValue: 207)

    public static let alreadyReported = HTTPStatusCode(rawValue: 208)

    public static let imUsed = HTTPStatusCode(rawValue: 226)

    public static let multipleChoices = HTTPStatusCode(rawValue: 300)

    public static let movedPermanently = HTTPStatusCode(rawValue: 301)

    public static let found = HTTPStatusCode(rawValue: 302)

    public static let seeOther = HTTPStatusCode(rawValue: 303)

    public static let notModified = HTTPStatusCode(rawValue: 304)

    public static let useProxy = HTTPStatusCode(rawValue: 305)

    public static let unused = HTTPStatusCode(rawValue: 306)

    public static let temporaryRedirect = HTTPStatusCode(rawValue: 307)

    public static let permanentRedirect = HTTPStatusCode(rawValue: 308)

    public static let badRequest = HTTPStatusCode(rawValue: 400)

    public static let unauthorized = HTTPStatusCode(rawValue: 401)

    public static let paymentRequired = HTTPStatusCode(rawValue: 402)

    public static let forbidden = HTTPStatusCode(rawValue: 403)

    public static let notFound = HTTPStatusCode(rawValue: 404)

    public static let methodNotAllowed = HTTPStatusCode(rawValue: 405)

    public static let notAcceptable = HTTPStatusCode(rawValue: 406)

    public static let proxyAuthenticationRequired = HTTPStatusCode(rawValue: 407)

    public static let requestTimeout = HTTPStatusCode(rawValue: 408)

    public static let conflict = HTTPStatusCode(rawValue: 409)

    public static let gone = HTTPStatusCode(rawValue: 410)

    public static let lengthRequired = HTTPStatusCode(rawValue: 411)

    public static let preconditionFailed = HTTPStatusCode(rawValue: 412)

    public static let payloadTooLarge = HTTPStatusCode(rawValue: 413)

    public static let uriTooLong = HTTPStatusCode(rawValue: 414)

    public static let unsupportedMediaType = HTTPStatusCode(rawValue: 415)

    public static let rangeNotSatisfiable = HTTPStatusCode(rawValue: 416)

    public static let expectationFailed = HTTPStatusCode(rawValue: 417)

    public static let misdirectedRequest = HTTPStatusCode(rawValue: 421)

    public static let unprocessableEntity = HTTPStatusCode(rawValue: 422)

    public static let locked = HTTPStatusCode(rawValue: 423)

    public static let failedDependency = HTTPStatusCode(rawValue: 424)

    public static let tooEarly = HTTPStatusCode(rawValue: 425)

    public static let upgradeRequired = HTTPStatusCode(rawValue: 426)

    public static let preconditionRequired = HTTPStatusCode(rawValue: 428)

    public static let tooManyRequests = HTTPStatusCode(rawValue: 429)

    public static let requestHeaderFieldsTooLarge = HTTPStatusCode(rawValue: 431)

    public static let unavailableForLegalReasons = HTTPStatusCode(rawValue: 451)

    public static let internalServerError = HTTPStatusCode(rawValue: 500)

    public static let notImplemented = HTTPStatusCode(rawValue: 501)

    public static let badGateway = HTTPStatusCode(rawValue: 502)

    public static let serviceUnavailable = HTTPStatusCode(rawValue: 503)

    public static let gatewayTimeout = HTTPStatusCode(rawValue: 504)

    public static let httpVersionNotSupported = HTTPStatusCode(rawValue: 505)

    public static let variantAlsoNegotiates = HTTPStatusCode(rawValue: 506)

    public static let insufficientStorage = HTTPStatusCode(rawValue: 507)

    public static let loopDetected = HTTPStatusCode(rawValue: 508)

    public static let notExtended = HTTPStatusCode(rawValue: 510)

    public static let networkAuthenticationRequired = HTTPStatusCode(rawValue: 511)
}
