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

    internal static func isRequestMacro(_ node: AttributeSyntax) -> Bool {
        guard let name = node.macroName else { return false }
        return name == "HTTPRequest" || name == "OPTIONS" || name == "GET"
            || name == "HEAD" || name == "POST" || name == "PUT" || name == "PATCH"
            || name == "DELETE" || name == "TRACE" || name == "CONNECT"
    }

    internal struct RequestInfo {
        var httpMethodName: ExprSyntax
        var variableNamesReferencedInPath: [String]?
        var pathSegments: [StringLiteralSegmentListSyntax.Element]?
    }

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext,
    ) throws -> [ExtensionDeclSyntax] {
        do {
            let requestInfo = try parseRequestInfo(node: node, declaration: declaration)
            return try generateConformance(type: type, conformingTo: protocols) {
                methodMember(requestInfo.httpMethodName)
                if let pathSegments = requestInfo.pathSegments {
                    try pathMember(pathSegments, context: context)
                }
            }
        } catch let error as RequestMacroDiagnostic {
            error.diagnose(macroNode: node, context: context)
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

    internal static func parseRequestInfo(
        node: AttributeSyntax,
        declaration: some DeclGroupSyntax,
    ) throws(RequestMacroDiagnostic) -> RequestInfo {
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
        if pathArgumentIndex >= args.count {
            return RequestInfo(httpMethodName: httpMethodName)
        }
        let pathArgument = args[pathArgumentIndex]

        guard let pathExpr = pathArgument.as(StringLiteralExprSyntax.self) else {
            throw .pathMustBeLiteral(pathArgument)
        }

        var newSegments: [StringLiteralSegmentListSyntax.Element] = []
        var variableNames: [String] = []
        for segment in pathExpr.segments {
            switch segment {
            case .stringSegment(let stringSegment):
                if case .stringSegment(let string) = stringSegment.content.tokenKind {
                    try string
                        .parseParameterNames(
                            into: &newSegments,
                            variableNames: &variableNames,
                            stringSegment,
                        )
                } else {
                    preconditionFailure("Expected stringSegment token kind")
                }
            default:
                newSegments.append(segment)
            }
        }

        return RequestInfo(
            httpMethodName: httpMethodName,
            variableNamesReferencedInPath: variableNames,
            pathSegments: newSegments,
        )
    }

    private static func pathMember(
        _ newSegments: [StringLiteralSegmentListSyntax.Element],
        context: some MacroExpansionContext,
    ) throws(RequestMacroDiagnostic) -> DeclSyntax {
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
        variableNames: inout [String],
        _ node: StringSegmentSyntax,
    ) throws(RequestMacroDiagnostic) {
        var parsingParameter = false
        var parsingUnicodeEscapeSequence = false
        var currentStringSegment: [Character] = []
        var paremeterNameStart = -1
        var currentParameterName: [Character] = []
        var offset = node.positionAfterSkippingLeadingTrivia.utf8Offset

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
                    throw .escapeSequenceInParameterName(node, offset: offset)
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
                    throw .unexpectedCharacterInPath("{", node, offset: offset)
                }
            } else if c == "}" {
                if parsingUnicodeEscapeSequence {
                    currentStringSegment.append(c)
                    parsingUnicodeEscapeSequence = false
                } else if parsingParameter {
                    let variableName = String(currentParameterName)
                    variableNames.append(variableName)
                    segments.append(
                        .expressionSegment(
                            ExpressionSegmentSyntax {
                                LabeledExprSyntax(
                                    expression: DeclReferenceExprSyntax(
                                        baseName: .identifier(variableName)
                                    )
                                )
                            }
                        )
                    )
                    currentParameterName.removeAll()
                    parsingParameter = false
                } else {
                    throw .unexpectedCharacterInPath("}", node, offset: offset)
                }
            } else if c == "/" {
                if parsingParameter {
                    throw .unterminatedParameterName(
                        String(currentParameterName),
                        node,
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
            throw .unterminatedParameterName(
                String(currentParameterName),
                node,
                offset: paremeterNameStart,
            )
        } else if !currentStringSegment.isEmpty {
            appendStringSegment()
        }
    }
}

internal enum RequestMacroDiagnostic: DiagnosticMessage, Error {
    case pathMustBeLiteral(ExprSyntax)
    case cannotBeAppliedToExtension
    case cannotBeAppliedToProtocol
    case unexpectedCharacterInPath(String, StringSegmentSyntax, offset: Int)
    case unterminatedParameterName(String, StringSegmentSyntax, offset: Int)
    case escapeSequenceInParameterName(StringSegmentSyntax, offset: Int)

    var message: String {
        switch self {
        case .pathMustBeLiteral:
            "The request path must be a string literal"
        case .cannotBeAppliedToExtension:
            "This macro cannot be applied to an extension"
        case .cannotBeAppliedToProtocol:
            "This macro cannot be applied to a protocol"
        case .unexpectedCharacterInPath(let char, _, _):
            "Unexpected '\(char)' in request path template"
        case .unterminatedParameterName(let name, _, _):
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

    func diagnose(macroNode: AttributeSyntax, context: MacroExpansionContext) {
        let diagnostic = switch self {
        case .pathMustBeLiteral(let exprSyntax):
            Diagnostic(node: exprSyntax, message: self)
        case .cannotBeAppliedToExtension:
            Diagnostic(node: macroNode, message: self)
        case .cannotBeAppliedToProtocol:
            Diagnostic(node: macroNode, message: self)
        case .unexpectedCharacterInPath(_, let stringSegment, let offset):
            Diagnostic(
                node: stringSegment,
                position: AbsolutePosition(utf8Offset: offset),
                message: self,
            )
        case .unterminatedParameterName(_, let stringSegment, let offset):
            Diagnostic(
                node: stringSegment,
                position: AbsolutePosition(utf8Offset: offset),
                message: self,
            )
        case .escapeSequenceInParameterName(let stringSegment, let offset):
            Diagnostic(
                node: stringSegment,
                position: AbsolutePosition(utf8Offset: offset),
                message: self,
            )
        }
        context.diagnose(diagnostic)
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

