//
//  HTTPStatusCode.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 12/04/2018.
//

public struct HTTPStatusCode: RawRepresentable, Hashable, Codable, Sendable {

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

    public var description: String {
        switch self {
        case .continue:
            return "Continue"
        case .switchingProtocols:
            return "Switching Protocols"
        case .processing:
            return "Processing"
        case .earlyHints:
            return "Early Hints"
        case .ok:
            return "OK"
        case .created:
            return "Created"
        case .accepted:
            return "Accepted"
        case .nonAuthoritativeInformation:
            return "Non-Authoritative Information"
        case .noContent:
            return "No Content"
        case .resetContent:
            return "Reset Content"
        case .partialContent:
            return "Partial Content"
        case .multiStatus:
            return "Multi-Status"
        case .alreadyReported:
            return "Already Reported"
        case .imUsed:
            return "IM Used"
        case .multipleChoices:
            return "Multiple Choices"
        case .movedPermanently:
            return "Moved Permanently"
        case .found:
            return "Found"
        case .seeOther:
            return "See Other"
        case .notModified:
            return "Not Modified"
        case .useProxy:
            return "Use Proxy"
        case .temporaryRedirect:
            return "Temporary Redirect"
        case .permanentRedirect:
            return "Permanent Redirect"
        case .badRequest:
            return "Bad Request"
        case .unauthorized:
            return "Unauthorized"
        case .paymentRequired:
            return "Payment Required"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not Found"
        case .methodNotAllowed:
            return "Method Not Allowed"
        case .notAcceptable:
            return "Not Acceptable"
        case .proxyAuthenticationRequired:
            return "Proxy Authentication Required"
        case .requestTimeout:
            return "Request Timeout"
        case .conflict:
            return "Conflict"
        case .gone:
            return "Gone"
        case .lengthRequired:
            return "Length Required"
        case .preconditionFailed:
            return "Precondition Failed"
        case .payloadTooLarge:
            return "Payload Too Large"
        case .uriTooLong:
            return "URI Too Long"
        case .unsupportedMediaType:
            return "Unsupported Media Type"
        case .rangeNotSatisfiable:
            return "Range Not Satisfiable"
        case .expectationFailed:
            return "Expectation Failed"
        case .misdirectedRequest:
            return "Misdirected Request"
        case .unprocessableEntity:
            return "Unprocessable Entity"
        case .locked:
            return "Locked"
        case .failedDependency:
            return "Failed Dependency"
        case .tooEarly:
            return "Too Early"
        case .upgradeRequired:
            return "Upgrade Required"
        case .preconditionRequired:
            return "Precondition Required"
        case .tooManyRequests:
            return "Too Many Requests"
        case .requestHeaderFieldsTooLarge:
            return "Request Header Fields Too Large"
        case .unavailableForLegalReasons:
            return "Unavailable For Legal Reasons"
        case .internalServerError:
            return "Internal Server Error"
        case .notImplemented:
            return "Not Implemented"
        case .badGateway:
            return "Bad Gateway"
        case .serviceUnavailable:
            return "Service Unavailable"
        case .gatewayTimeout:
            return "Gateway Timeout"
        case .httpVersionNotSupported:
            return "HTTP Version Not Supported"
        case .variantAlsoNegotiates:
            return "Variant Also Negotiates"
        case .insufficientStorage:
            return "Insufficient Storage"
        case .loopDetected:
            return "Loop Detected"
        case .notExtended:
            return "Not Extended"
        case .networkAuthenticationRequired:
            return "Network Authentication Required"
        default:
            return "Error \(rawValue)"
        }

    }
}

extension HTTPStatusCode: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "\(rawValue): \(description)"
    }
}

extension HTTPStatusCode {

    /// 100 Continue
    public static let `continue` = HTTPStatusCode(rawValue: 100)

    /// 101 Switching Protocols
    public static let switchingProtocols = HTTPStatusCode(rawValue: 101)

    /// 102 Processing
    public static let processing = HTTPStatusCode(rawValue: 102)

    /// 103 Early Hints
    public static let earlyHints = HTTPStatusCode(rawValue: 103)

    /// 200 OK
    public static let ok = HTTPStatusCode(rawValue: 200)

    /// 201 Created
    public static let created = HTTPStatusCode(rawValue: 201)

    /// 202 Accepted
    public static let accepted = HTTPStatusCode(rawValue: 202)

    /// 203 Non-Authoritative Information
    public static let nonAuthoritativeInformation = HTTPStatusCode(rawValue: 203)

    /// 204 No Content
    public static let noContent = HTTPStatusCode(rawValue: 204)

    /// 205 Reset Content
    public static let resetContent = HTTPStatusCode(rawValue: 205)

    /// 206 Partial Content
    public static let partialContent = HTTPStatusCode(rawValue: 206)

    /// 207 Multi-Status
    public static let multiStatus = HTTPStatusCode(rawValue: 207)

    /// 208 Already Reported
    public static let alreadyReported = HTTPStatusCode(rawValue: 208)

    /// 226 IM Used
    public static let imUsed = HTTPStatusCode(rawValue: 226)

    /// 300 Multiple Choices
    public static let multipleChoices = HTTPStatusCode(rawValue: 300)

    /// 301 Moved Permanently
    public static let movedPermanently = HTTPStatusCode(rawValue: 301)

    /// 302 Found
    public static let found = HTTPStatusCode(rawValue: 302)

    /// 303 See Other
    public static let seeOther = HTTPStatusCode(rawValue: 303)

    /// 304 Not Modified
    public static let notModified = HTTPStatusCode(rawValue: 304)

    /// 305 Use Proxy
    public static let useProxy = HTTPStatusCode(rawValue: 305)

    /// 307 Temporary Redirect
    public static let temporaryRedirect = HTTPStatusCode(rawValue: 307)

    /// 308 Permanent Redirect
    public static let permanentRedirect = HTTPStatusCode(rawValue: 308)

    /// 400 Bad Request
    public static let badRequest = HTTPStatusCode(rawValue: 400)

    /// 401 Unauthorized
    public static let unauthorized = HTTPStatusCode(rawValue: 401)

    /// 402 Payment Required
    public static let paymentRequired = HTTPStatusCode(rawValue: 402)

    /// 403 Forbidden
    public static let forbidden = HTTPStatusCode(rawValue: 403)

    /// 404 Not Found
    public static let notFound = HTTPStatusCode(rawValue: 404)

    /// 405 Method Not Allowed
    public static let methodNotAllowed = HTTPStatusCode(rawValue: 405)

    /// 406 Not Acceptable
    public static let notAcceptable = HTTPStatusCode(rawValue: 406)

    /// 407 Proxy Authentication Required
    public static let proxyAuthenticationRequired = HTTPStatusCode(rawValue: 407)

    /// 408 Request Timeout
    public static let requestTimeout = HTTPStatusCode(rawValue: 408)

    /// 409 Conflict
    public static let conflict = HTTPStatusCode(rawValue: 409)

    /// 410 Gone
    public static let gone = HTTPStatusCode(rawValue: 410)

    /// 411 Length Required
    public static let lengthRequired = HTTPStatusCode(rawValue: 411)

    /// 412 Precondition Failed
    public static let preconditionFailed = HTTPStatusCode(rawValue: 412)

    /// 413 Payload Too Large
    public static let payloadTooLarge = HTTPStatusCode(rawValue: 413)

    /// 414 URI Too Long
    public static let uriTooLong = HTTPStatusCode(rawValue: 414)

    /// 415 Unsupported Media Type
    public static let unsupportedMediaType = HTTPStatusCode(rawValue: 415)

    /// 416 Range Not Satisfiable
    public static let rangeNotSatisfiable = HTTPStatusCode(rawValue: 416)

    /// 417 Expectation Failed
    public static let expectationFailed = HTTPStatusCode(rawValue: 417)

    /// 421 Misdirected Request
    public static let misdirectedRequest = HTTPStatusCode(rawValue: 421)

    /// 422 Unprocessable Entity
    public static let unprocessableEntity = HTTPStatusCode(rawValue: 422)

    /// 423 Locked
    public static let locked = HTTPStatusCode(rawValue: 423)

    /// 424 Failed Dependency
    public static let failedDependency = HTTPStatusCode(rawValue: 424)

    /// 425 Too Early
    public static let tooEarly = HTTPStatusCode(rawValue: 425)

    /// 426 Upgrade Required
    public static let upgradeRequired = HTTPStatusCode(rawValue: 426)

    /// 428 Precondition Required
    public static let preconditionRequired = HTTPStatusCode(rawValue: 428)

    /// 429 Too Many Requests
    public static let tooManyRequests = HTTPStatusCode(rawValue: 429)

    /// 431 Request Header Fields Too Large
    public static let requestHeaderFieldsTooLarge = HTTPStatusCode(rawValue: 431)

    /// 451 Unavailable For Legal Reasons
    public static let unavailableForLegalReasons = HTTPStatusCode(rawValue: 451)

    /// 500 Internal Server Error
    public static let internalServerError = HTTPStatusCode(rawValue: 500)

    /// 501 Not Implemented
    public static let notImplemented = HTTPStatusCode(rawValue: 501)

    /// 502 Bad Gateway
    public static let badGateway = HTTPStatusCode(rawValue: 502)

    /// 503 Service Unavailable
    public static let serviceUnavailable = HTTPStatusCode(rawValue: 503)

    /// 504 Gateway Timeout
    public static let gatewayTimeout = HTTPStatusCode(rawValue: 504)

    /// 505 HTTP Version Not Supported
    public static let httpVersionNotSupported = HTTPStatusCode(rawValue: 505)

    /// 506 Variant Also Negotiates
    public static let variantAlsoNegotiates = HTTPStatusCode(rawValue: 506)

    /// 507 Insufficient Storage
    public static let insufficientStorage = HTTPStatusCode(rawValue: 507)

    /// 508 Loop Detected
    public static let loopDetected = HTTPStatusCode(rawValue: 508)

    /// 510 Not Extended
    public static let notExtended = HTTPStatusCode(rawValue: 510)

    /// 511 Network Authentication Required
    public static let networkAuthenticationRequired = HTTPStatusCode(rawValue: 511)
}
