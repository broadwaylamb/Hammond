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
        guard let macroName = node
            .attributeName
            .as(IdentifierTypeSyntax.self)?
            .name
            .identifier?
            .name
        else {
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
            return [
                try ExtensionDeclSyntax(
                    extendedType: type,
                    inheritanceClause: InheritanceClauseSyntax {
                        for `protocol` in protocols {
                            InheritedTypeSyntax(type: `protocol`)
                        }
                    },
                    memberBlockBuilder: {
                        methodMember(httpMethodName)
                        queryItemsMember()
                        if pathArgumentIndex < args.count {
                            try pathMember(args[pathArgumentIndex], context: context)
                        }
                    }
                )
            ]
        } catch is RequestMacroDiagnostic {
            return []
        }
    }

    private static func methodMember(
        _ httpMethodName: ExprSyntax,
    ) -> DeclSyntax {
        """
        static let method = Hammond.HTTPMethod(rawValue: \(httpMethodName))
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

        return """
        var path: Swift.String {
            return \(pathExpr)
        }
        """
    }

    private static func queryItemsMember() -> DeclSyntax {
        return """
        var queryItems: [(key: Swift.String, value: Swift.String?)]? {
            return nil
        }
        """
    }
}

private enum RequestMacroDiagnostic: String, DiagnosticMessage, Error {
    case pathMustBeLiteral
    case cannotBeAppliedToExtension
    case cannotBeAppliedToProtocol

    var message: String {
        switch self {
        case .pathMustBeLiteral:
            "The request path must be a string literal"
        case .cannotBeAppliedToExtension:
            "This macro cannot be applied to an extension"
        case .cannotBeAppliedToProtocol:
            "This macro cannot be applied to a protocol"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "com.broadwaylamb.Hammond.\(Self.self)", id: "\(rawValue)")
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

private extension AttributeSyntax {
    func getMacroArguments() -> [ExprSyntax] {
        guard let exprList = arguments?.as(LabeledExprListSyntax.self) else {
            return []
        }
        return exprList.map { $0.expression }
    }
}
