//
//  RequestMacroTests.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 29/06/2025.
//

import Testing
import HammondMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport

struct RequestMacroTests {
    @Test func predefinedHTTPMethods() {
        assertMacroExpansion(
            #"""
            @GET("/myget/{a}/{b}")
            struct MyGetRequest {
                var a: Int
                var b: String
            }
            """#,
            expandedSource: #"""
            struct MyGetRequest {
                var a: Int
                var b: String
            }
            
            extension MyGetRequest: RequestProtocol {
                static let method = Hammond.HTTPMethod(rawValue: "GET")
                var path: Swift.String {
                    return "/myget/\(a)/\(b)"
                }
            }
            """#,
            macroSpecs: testMacros,
        )
    }

    @Test func arbitraryHTTPMethod() {
        assertMacroExpansion(
            """
            @HTTPRequest("whatever123", "/foobar")
            struct MyGetRequest {}
            """,
            expandedSource: """
            struct MyGetRequest {}
            
            extension MyGetRequest: RequestProtocol {
                static let method = Hammond.HTTPMethod(rawValue: "whatever123")
                var path: Swift.String {
                    return "/foobar"
                }
            }
            """,
            macroSpecs: testMacros,
        )
    }

    @Test func escapedUnicodeCharacterInPath() {
        assertMacroExpansion(
            #"""
            @GET("/myget/\u{41}")
            struct MyGetRequest {
                var a: Int
                var b: String
            }
            """#,
            expandedSource: #"""
            struct MyGetRequest {
                var a: Int
                var b: String
            }
            
            extension MyGetRequest: RequestProtocol {
                static let method = Hammond.HTTPMethod(rawValue: "GET")
                var path: Swift.String {
                    return "/myget/\u{41}"
                }
            }
            """#,
            macroSpecs: testMacros,
        )
    }

    @Test func unicodeEscapeSequenceInParameterName() {
        assertMacroExpansion(
            #"""
            @GET("/myget/{param\u{41}}")
            struct MyGetRequest {
                var a: Int
                var b: String
            }
            """#,
            expandedSource: #"""
            struct MyGetRequest {
                var a: Int
                var b: String
            }
            """#,
            diagnostics: [
                DiagnosticSpec(
                    message: "Unicode escape sequences in parameter names are not allowed",
                    line: 1,
                    column: 21,
                    severity: .error,
                ),
            ],
            macroSpecs: testMacros,
        )
    }

    @Test func customPathInBody() {
        assertMacroExpansion(
            """
            @POST
            struct MyGetRequest {
                var path: String
            }
            """,
            expandedSource: """
            struct MyGetRequest {
                var path: String
            }
            
            extension MyGetRequest: RequestProtocol {
                static let method = Hammond.HTTPMethod(rawValue: "POST")
            }
            """,
            macroSpecs: testMacros,
        )
    }

    @Test func nonLiteralArguments() {
        assertMacroExpansion(
            """
            let get = "GET"
            let path = "/path"
            @HTTPRequest(get, path)
            struct MyGetRequest {}
            """,
            expandedSource: """
            let get = "GET"
            let path = "/path"
            struct MyGetRequest {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "The request path must be a string literal",
                    line: 3,
                    column: 19,
                    severity: .error,
                )
            ],
            macroSpecs: testMacros,
        )
    }

    @Test func cannotBeAppliedToProtocol() {
        assertMacroExpansion(
            #"""
            @HTTPRequest("GET", "/myget")
            protocol MyGetRequest {}
            """#,
            expandedSource: #"""
            protocol MyGetRequest {}
            """#,
            diagnostics: [
                DiagnosticSpec(
                    message: "This macro cannot be applied to a protocol",
                    line: 1,
                    column: 1,
                    severity: .error,
                )
            ],
            macroSpecs: testMacros,
        )
    }

    @Test func cannotBeAppliedToExtension() {
        assertMacroExpansion(
            #"""
            @HTTPRequest("GET", "/myget")
            extension String {}
            """#,
            expandedSource: #"""
            extension String {}
            """#,
            diagnostics: [
                DiagnosticSpec(
                    message: "This macro cannot be applied to an extension",
                    line: 1,
                    column: 1,
                    severity: .error,
                )
            ],
            macroSpecs: testMacros,
        )
    }

    @Test func queryWithoutTypeAnnotation() {
        assertMacroExpansion(
            """
            struct MyGetRequest {
                @Query var a = 1
            }
            """,
            expandedSource: """
            struct MyGetRequest {
                var a = 1
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Type annotation is mandatory for '@Query' properties",
                    line: 2,
                    column: 5,
                ),
            ],
            macroSpecs: testMacros,
        )
    }

    @Test func pathTemplateErrors() {
        assertMacroExpansion(
            #"""
            @GET("/myget/{foo")
            struct MyGetRequest {
            }
            
            @GET("/myget/{bar/}")
            struct MyGetRequest2 {
            }
            
            @GET("/{{baz}}")
            struct MyGetRequest3 {
            }
            
            @GET("/hi}")
            struct MyGetRequest4 {
            }
            """#,
            expandedSource: #"""
            struct MyGetRequest {
            }
            struct MyGetRequest2 {
            }
            struct MyGetRequest3 {
            }
            struct MyGetRequest4 {
            }
            """#,
            diagnostics: [
                DiagnosticSpec(
                    message: "Unterminated parameter name 'foo'",
                    line: 1,
                    column: 15,
                    severity: .error,
                ),
                DiagnosticSpec(
                    message: "Unterminated parameter name 'bar'",
                    line: 5,
                    column: 15,
                    severity: .error,
                ),
                DiagnosticSpec(
                    message: "Unexpected '{' in request path template",
                    line: 9,
                    column: 10,
                    severity: .error,
                ),
                DiagnosticSpec(
                    message: "Unexpected '}' in request path template",
                    line: 13,
                    column: 11,
                    severity: .error,
                ),
            ],
            macroSpecs: testMacros,
        )
    }

    @Test func encodableRequest() {
        assertMacroExpansion(
            #"""
            @EncodableRequest
            struct MyRequest {
                @Query var a: Int
                @Query(key: "bb") var b: String
                var c: String
                var d: UInt, e: UInt8, f: UInt16
            
                var computedProperty: String { fatalError() }
            
                @Query var computedQueryProperty: String { c }
            }
            """#,
            expandedSource: #"""
            struct MyRequest {
                var a: Int
                var b: String
                var c: String
                var d: UInt, e: UInt8, f: UInt16

                var computedProperty: String { fatalError() }

                var computedQueryProperty: String { c }
            }

            extension MyRequest: EncodableRequestProtocol {
                struct __macro_local_14EncodableQueryfMu_: Swift.Encodable {
                    let a: Int
                    let b: String
                    let computedQueryProperty: String
                    enum CodingKeys: String, CodingKey {
                        case a
                        case b = "bb"
                        case computedQueryProperty
                    }
                }
                var encodableQuery: (some Swift.Encodable)? {
                    return __macro_local_14EncodableQueryfMu_(a: a, b: b, computedQueryProperty: computedQueryProperty)
                }
                struct __macro_local_13EncodableBodyfMu_: Swift.Encodable {
                    let c: String
                    let d: UInt
                    let e: UInt8
                    let f: UInt16
                    enum CodingKeys: String, CodingKey {
                        case c
                        case d
                        case e
                        case f
                    }
                }
                var encodableBody: (some Swift.Encodable)? {
                    return __macro_local_13EncodableBodyfMu_(c: c, d: d, e: e, f: f)
                }
            }
            """#,
            macroSpecs: testMacros,
        )
    }

    @Test func encodableRequestWithoutQuery() {
        assertMacroExpansion(
            #"""
            @EncodableRequest
            struct MyRequest {
                var inBody: String
            }
            """#,
            expandedSource: #"""
            struct MyRequest {
                var inBody: String
            }

            extension MyRequest: EncodableRequestProtocol {
                struct __macro_local_13EncodableBodyfMu_: Swift.Encodable {
                    let inBody: String
                    enum CodingKeys: String, CodingKey {
                        case inBody
                    }
                }
                var encodableBody: (some Swift.Encodable)? {
                    return __macro_local_13EncodableBodyfMu_(inBody: inBody)
                }
            }
            """#,
            macroSpecs: testMacros,
        )
    }

    @Test func encodableRequestWithoutBody() {
        assertMacroExpansion(
            #"""
            @EncodableRequest
            struct MyRequest {
                @Query var inQuery: String
            }
            """#,
            expandedSource: #"""
            struct MyRequest {
                var inQuery: String
            }

            extension MyRequest: EncodableRequestProtocol {
                struct __macro_local_14EncodableQueryfMu_: Swift.Encodable {
                    let inQuery: String
                    enum CodingKeys: String, CodingKey {
                        case inQuery
                    }
                }
                var encodableQuery: (some Swift.Encodable)? {
                    return __macro_local_14EncodableQueryfMu_(inQuery: inQuery)
                }
            }
            """#,
            macroSpecs: testMacros,
        )
    }
}

private let requestMacros: [String : MacroSpec] = Dictionary(
    ["HTTPRequest", "GET", "POST"]
        .map {
            ($0, MacroSpec(type: RequestMacro.self, conformances: ["RequestProtocol"]))
        },
    uniquingKeysWith: { $1 },
)

private let encodableRequestMacros: [String : MacroSpec] = Dictionary(
    ["EncodableRequest"]
        .map {
            (
                $0,
                MacroSpec(
                    type: EncodableRequestMacro.self,
                    conformances: ["EncodableRequestProtocol"]
                ),
            )
        },
    uniquingKeysWith: { $1 },
)

private let markerMacros: [String : MacroSpec] = Dictionary(
    ["Query"]
        .map {
            ($0, MacroSpec(type: MarkerMacro.self))
        },
    uniquingKeysWith: { $1 },
)

private let testMacros = requestMacros
    .merging(markerMacros, uniquingKeysWith: { $1 })
    .merging(encodableRequestMacros, uniquingKeysWith: { $1 })

