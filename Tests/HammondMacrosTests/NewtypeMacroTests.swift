//
//  NewtypeMacroTests.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 05/07/2025.
//

import Testing
import HammondMacroEngine
import SwiftSyntaxMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport

struct NewtypeMacroTests {
    @Test func newtypeMacro() {
        assertMacroExpansion(
            """
            @Newtype<Int>
            struct S {}
            """,
            expandedSource: """
            struct S {

                public var rawValue: Int

                public init(rawValue: Int) {
                    self.rawValue = rawValue
                }
            }

            extension S: RawRepresentable, Codable, Hashable, Equatable, CustomDebugStringConvertible {
                public var description: Swift.String {
                    return Swift.String(describing: rawValue)
                }
                public var debugDescription: Swift.String {
                    return Swift.String(reflecting: rawValue)
                }
            }
            """,
            macroSpecs: testMacros,
        )
    }

    @Test func missingGenericArgument() async throws {
        assertMacroExpansion(
            """
            @Newtype
            struct S {}
            """,
            expandedSource: """
            struct S {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Missing generic argument in the macro",
                    line: 1,
                    column: 1,
                )
            ],
            macroSpecs: testMacros,
        )
    }
}

private let testMacros: [String : MacroSpec] = [
    "Newtype" : MacroSpec(
        type: NewtypeMacro.self,
        conformances: [
            "RawRepresentable",
            "Codable",
            "Hashable",
            "Equatable",
            "CustomDebugStringConvertible",
        ]
    )
]
