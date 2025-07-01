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
                var queryItems: [(key: Swift.String, value: Swift.String?)]? {
                    return nil
                }
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
                var queryItems: [(key: Swift.String, value: Swift.String?)]? {
                    return nil
                }
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
                var queryItems: [(key: Swift.String, value: Swift.String?)]? {
                    return nil
                }
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
                var queryItems: [(key: Swift.String, value: Swift.String?)]? {
                    return nil
                }
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

    @Test func customQueryItems() {
        assertMacroExpansion(
            """
            @GET("/foobar")
            struct MyGetRequest {
                var queryItems: [(key: String, value: String?)]? {
                    fatalError()
                }
            }
            """,
            expandedSource: """
            struct MyGetRequest {
                var queryItems: [(key: String, value: String?)]? {
                    fatalError()
                }
            }
            
            extension MyGetRequest: RequestProtocol {
                static let method = Hammond.HTTPMethod(rawValue: "GET")
                var path: Swift.String {
                    return "/foobar"
                }
            }
            """,
            macroSpecs: testMacros,
        )
    }

    @Test func staticQueryItems() {
        assertMacroExpansion(
            """
            @GET("/foobar")
            struct MyGetRequest {
                static var queryItems: [(key: String, value: String?)]? {
                    fatalError()
                }
            }
            """,
            expandedSource: """
            struct MyGetRequest {
                static var queryItems: [(key: String, value: String?)]? {
                    fatalError()
                }
            }
            
            extension MyGetRequest: RequestProtocol {
                static let method = Hammond.HTTPMethod(rawValue: "GET")
                var queryItems: [(key: Swift.String, value: Swift.String?)]? {
                    return nil
                }
                var path: Swift.String {
                    return "/foobar"
                }
            }
            """,
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
}

private let testMacros: [String : MacroSpec] = Dictionary(
    ["HTTPRequest", "GET", "POST"]
        .map {
            ($0, MacroSpec(type: RequestMacro.self, conformances: ["RequestProtocol"]))
        },
    uniquingKeysWith: { $1 },
)

