//
//  NewtypeMacro.swift
//  Hammond
//
//  Created by Sergej Jaskiewicz on 05/07/2025.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct NewtypeMacro: ExtensionMacro, MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        if node.underlyingType == nil {
            return []
        }
        return try generateConformance(type: type, conformingTo: protocols) {
            try VariableDeclSyntax("public var description: Swift.String") {
                """
                return Swift.String(describing: rawValue)
                """
            }
            try VariableDeclSyntax("public var debugDescription: Swift.String") {
                """
                return Swift.String(reflecting: rawValue)
                """
            }
        }
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let underlyingType = node.underlyingType else {
            throw NewtypeMacroDiagnostic.missingGenericArgument
        }

        return [
            """
            public var rawValue: \(underlyingType)
            """,
            """
            public init(rawValue: \(underlyingType)) {
                self.rawValue = rawValue
            }
            """
        ]
    }
}

extension AttributeSyntax {
    fileprivate var underlyingType: TypeSyntax? {
        guard case .type(let underlyingType) = self
            .attributeName
            .as(IdentifierTypeSyntax.self)?
            .genericArgumentClause?
            .arguments
            .first?
            .argument
        else {
            return nil
        }
        return underlyingType
    }
}

private enum NewtypeMacroDiagnostic: String, DiagnosticMessage, Error {
    case missingGenericArgument

    var message: String {
        switch self {
        case .missingGenericArgument:
            "Missing generic argument in the macro"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "com.broadwaylamb.Hammond.\(Self.self)", id: rawValue)
    }

    var severity: DiagnosticSeverity {
        .error
    }
}
