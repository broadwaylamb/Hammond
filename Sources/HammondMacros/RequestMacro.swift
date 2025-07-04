//
//  RequestMacro.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 29/06/2025.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RequestMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext,
    ) throws -> [ExtensionDeclSyntax] {
        if declaration is ProtocolDeclSyntax {
            throw RequestMacroDiagnostic.cannotBeAppliedToProtocol
        }
        if declaration is ExtensionDeclSyntax {
            throw RequestMacroDiagnostic.cannotBeAppliedToExtension
        }
        guard let macroName = node.macroName else {
            fatalError("Missing macro name in \(node)")
        }
        let args = node.getMacroArguments()
        let httpMethodName: ExprSyntax
        let pathArgumentIndex: Int
        if macroName == "HTTPRequest" {
            precondition(args.count >= 1, "Expected 2 macro arguments in \(node)")
            httpMethodName = args[0]
            pathArgumentIndex = 1
        } else {
            httpMethodName = ExprSyntax(StringLiteralExprSyntax(content: macroName))
            pathArgumentIndex = 0
        }

        do {
            return try generateConformance(type: type, conformingTo: protocols) {
                methodMember(httpMethodName)
                if pathArgumentIndex < args.count {
                    try pathMember(args[pathArgumentIndex], context: context)
                }
            }
        } catch is RequestMacroDiagnostic {
            return []
        }
    }

    private static func methodMember(
        _ httpMethodName: ExprSyntax,
    ) -> DeclSyntax {
        """
        public static let method = Hammond.HTTPMethod(rawValue: \(httpMethodName))
        """
    }

    private static func pathMember(
        _ pathArgument: ExprSyntax,
        context: some MacroExpansionContext,
    ) throws(RequestMacroDiagnostic) -> DeclSyntax {
        guard let pathExpr = pathArgument.as(StringLiteralExprSyntax.self)
        else {
            context.diagnose(
                Diagnostic(
                    node: pathArgument,
                    message: RequestMacroDiagnostic.pathMustBeLiteral,
                )
            )
            throw .pathMustBeLiteral
        }

        var newSegments: [StringLiteralSegmentListSyntax.Element] = []
        for segment in pathExpr.segments {
            switch segment {
            case .stringSegment(let stringSegment):
                if case .stringSegment(let string) = stringSegment.content.tokenKind {
                    try string.parseParameterNames(
                        into: &newSegments,
                        stringSegment,
                        context: context,
                    )
                } else {
                    preconditionFailure("Expected stringSegment token kind")
                }
            default:
                newSegments.append(segment)
            }
        }

        let newStringLiteral = StringLiteralExprSyntax(
            openingQuote: .stringQuoteToken(),
            segments: StringLiteralSegmentListSyntax(newSegments),
            closingQuote: .stringQuoteToken(),
        )

        return """
        public var path: Swift.String {
            return \(newStringLiteral)
        }
        """
    }
}

private extension String {
    func parseParameterNames(
        into segments: inout [StringLiteralSegmentListSyntax.Element],
        _ node: StringSegmentSyntax,
        context: some MacroExpansionContext,
    ) throws(RequestMacroDiagnostic) {
        var parsingParameter = false
        var parsingUnicodeEscapeSequence = false
        var currentStringSegment: [Character] = []
        var paremeterNameStart = -1
        var currentParameterName: [Character] = []
        var offset = node.positionAfterSkippingLeadingTrivia.utf8Offset

        func diagnose(
            _ message: RequestMacroDiagnostic,
            offset: Int,
        ) throws(RequestMacroDiagnostic) -> Never {
            context.diagnose(
                Diagnostic(
                    node: node,
                    position: AbsolutePosition(utf8Offset: offset),
                    message: message,
                )
            )
            throw message
        }

        func appendStringSegment() {
            segments.append(
                .stringSegment(
                    StringSegmentSyntax(
                        content: .stringSegment(String(currentStringSegment))
                    )
                )
            )
        }

        for slice in lookahead(3) {
            let c = slice.first!
            offset += c.utf8.count
            if slice == "\\u{" {
                if parsingParameter {
                    try diagnose(.escapeSequenceInParameterName, offset: offset)
                }
                parsingUnicodeEscapeSequence = true
            }
            if c == "{" {
                if parsingUnicodeEscapeSequence {
                    currentStringSegment.append(c)
                } else if !parsingParameter {
                    appendStringSegment()
                    currentStringSegment = []
                    // Start parsing the parameter name until we meet '}'
                    parsingParameter = true
                    paremeterNameStart = offset
                } else {
                    try diagnose(.unexpectedCharacterInPath("{"), offset: offset)
                }
            } else if c == "}" {
                if parsingUnicodeEscapeSequence {
                    currentStringSegment.append(c)
                    parsingUnicodeEscapeSequence = false
                } else if parsingParameter {
                    segments.append(
                        .expressionSegment(
                            ExpressionSegmentSyntax {
                                LabeledExprSyntax(
                                    expression: DeclReferenceExprSyntax(
                                        baseName: .identifier(
                                            String(currentParameterName)
                                        )
                                    )
                                )
                            }
                        )
                    )
                    currentParameterName.removeAll()
                    parsingParameter = false
                } else {
                    try diagnose(.unexpectedCharacterInPath("}"), offset: offset)
                }
            } else if c == "/" {
                if parsingParameter {
                    try diagnose(
                        .unterminatedParameterName(String(currentParameterName)),
                        offset: paremeterNameStart,
                    )
                } else {
                    currentStringSegment.append(c)
                }
            } else {
                if parsingParameter {
                    currentParameterName.append(c)
                } else {
                    currentStringSegment.append(c)
                }
            }
        }
        if parsingParameter {
            try diagnose(
                .unterminatedParameterName(String(currentParameterName)),
                offset: paremeterNameStart,
            )
        } else if !currentStringSegment.isEmpty {
            appendStringSegment()
        }
    }
}

private enum RequestMacroDiagnostic: DiagnosticMessage, Error {
    case pathMustBeLiteral
    case cannotBeAppliedToExtension
    case cannotBeAppliedToProtocol
    case unexpectedCharacterInPath(String)
    case unterminatedParameterName(String)
    case escapeSequenceInParameterName

    var message: String {
        switch self {
        case .pathMustBeLiteral:
            "The request path must be a string literal"
        case .cannotBeAppliedToExtension:
            "This macro cannot be applied to an extension"
        case .cannotBeAppliedToProtocol:
            "This macro cannot be applied to a protocol"
        case .unexpectedCharacterInPath(let char):
            "Unexpected '\(char)' in request path template"
        case .unterminatedParameterName(let name):
            "Unterminated parameter name '\(name)'"
        case .escapeSequenceInParameterName:
            "Unicode escape sequences in parameter names are not allowed"
        }
    }

    var diagnosticID: MessageID {
        let id = switch self {
        case .pathMustBeLiteral:
            "pathMustBeLiteral"
        case .cannotBeAppliedToExtension:
            "cannotBeAppliedToExtension"
        case .cannotBeAppliedToProtocol:
            "cannotBeAppliedToExtension"
        case .unexpectedCharacterInPath:
            "unexpectedCharacterInPath"
        case .unterminatedParameterName:
            "unterminatedParameterName"
        case .escapeSequenceInParameterName:
            "escapeSequenceInParameterName"
        }
        return MessageID(domain: "com.broadwaylamb.Hammond.\(Self.self)", id: id)
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

