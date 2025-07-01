//
//  MarkerMacro.swift
//  Hammond
//
//  Created by sergej on 30.06.2025.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct MarkerMacro: PeerMacro {
    public static func expansion(
      of node: AttributeSyntax,
      providingPeersOf declaration: some DeclSyntaxProtocol,
      in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varDecl = declaration.as(VariableDeclSyntax.self) else {
            context
                .addDiagnostics(
                    from: MarkerMacroDiagnostic.appliesOnlyToProperties,
                    node: node,
                )
            return []
        }
        guard let macroName = node.macroName else {
            return []
        }
        if varDecl.bindings.count != 1 {
            context
                .addDiagnostics(
                    from: MarkerMacroDiagnostic.appliesToSingleVariable,
                    node: node,
                )
            return []
        }
        if macroName == "Query" && varDecl.bindings.first!.typeAnnotation == nil {
            context
                .addDiagnostics(
                    from: MarkerMacroDiagnostic.queryPropertyTypeIsMandatory,
                    node: node,
                )
            return []
        }
        return []
    }
}

private enum MarkerMacroDiagnostic: String, DiagnosticMessage, Error {
    case appliesOnlyToProperties
    case appliesToSingleVariable
    case queryPropertyTypeIsMandatory

    var message: String {
        switch self {
        case .appliesOnlyToProperties:
            "This macro can only be applied to a property"
        case .appliesToSingleVariable:
            "This macro can only be applied to a single variable"
        case .queryPropertyTypeIsMandatory:
            "Type annotation is mandatory for '@Query' properties"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "com.broadwaylamb.Hammond.\(Self.self)", id: rawValue)
    }

    var severity: DiagnosticSeverity {
        .error
    }
}
