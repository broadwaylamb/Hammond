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
            @GET("/myget/\(a)/\(b)")
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
}

private let testMacros: [String : MacroSpec] = Dictionary(
    ["HTTPRequest", "GET", "POST"]
        .map {
            ($0, MacroSpec(type: RequestMacro.self, conformances: ["RequestProtocol"]))
        },
    uniquingKeysWith: { $1 },
)

