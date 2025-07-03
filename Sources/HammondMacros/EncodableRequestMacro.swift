//
//  EncodableRequestMacro.swift
//  Hammond
//
//  Created by sergej on 01.07.2025.
//

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct EncodableRequestMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        do {
            let varDecls = declaration.varDecls
            let queryVars: [CodingKey] = try varDecls
                .compactMap { try parseCodingKey($0, macroName: "Query") }

            let restVars: [CodingKey] = try varDecls.flatMap { varDecl -> [CodingKey] in
                if !varDecl.getMacros(name: "Query").isEmpty { return [] }
                return try varDecl.bindings
                    .compactMap { binding -> CodingKey? in
                        if binding.accessorBlock != nil {
                            return nil
                        }
                        guard let type = binding.typeAnnotation else {
                            let error = EncodableRequestMacroDiagnostic
                                .typeAnnotationIsMandatory
                            context.addDiagnostics(from: error, node: binding)
                            throw error
                        }
                        guard let identifier = binding.propertyName else {
                            return nil
                        }
                        return CodingKey(identifier: identifier, type: type.type)
                    }
            }

            return try generateConformance(type: type, conformingTo: protocols) {
                if !queryVars.isEmpty {
                    let structName = TokenSyntax.identifier("EncodableQuery")
                    try encodableStruct(queryVars, structName: structName)
                    try encodableProperty(
                        queryVars,
                        propertyName: "encodableQuery",
                        structName: structName,
                    )
                }
                if !restVars.isEmpty {
                    let structName = TokenSyntax.identifier("EncodableBody")
                    try encodableStruct(restVars, structName: structName)
                    try encodableProperty(
                        restVars,
                        propertyName: "encodableBody",
                        structName: structName,
                    )
                }
            }
        } catch is EncodableRequestMacroDiagnostic {
            return []
        }
    }

    private static func parseCodingKey(
        _ decl: VariableDeclSyntax,
        macroName: String
    ) throws -> CodingKey? {
        guard let binding = decl.bindings.first else {
            return nil
        }
        guard let macro = decl.getMacros(name: macroName).first,
              let declName = binding.propertyName
        else {
            return nil
        }
        guard let type = binding.typeAnnotation?.type else {
            return nil
        }
        let keyExpr = macro.getMacroArgument(withLabel: "key")
        return CodingKey(key: keyExpr, identifier: declName, type: type)
    }

    private static func encodableStruct(
        _ codingKeys: [CodingKey],
        structName: TokenSyntax,
    ) throws -> StructDeclSyntax {
        try StructDeclSyntax("struct \(structName): Swift.Encodable") {
            for codingKey in codingKeys {
                VariableDeclSyntax(
                    .let,
                    name: PatternSyntax(
                        fromProtocol: IdentifierPatternSyntax(
                            identifier: .identifier(codingKey.identifier)
                        )
                    ),
                    type: TypeAnnotationSyntax(type: codingKey.type),
                )
            }
            try codingKeys.generateCodingKeysEnum()
        }
    }

    private static func encodableProperty(
        _ codingKeys: [CodingKey],
        propertyName: String,
        structName: TokenSyntax,
    ) throws -> VariableDeclSyntax {
        let varName = TokenSyntax.identifier(propertyName)
        return try VariableDeclSyntax("var \(varName): \(structName)") {
            ReturnStmtSyntax(
                expression: FunctionCallExprSyntax(
                    callee: DeclReferenceExprSyntax(baseName: structName)
                ) {
                    for codingKey in codingKeys {
                        LabeledExprSyntax(
                            label: .identifier(codingKey.identifier),
                            colon: .colonToken(),
                            expression: DeclReferenceExprSyntax(
                                baseName: .identifier(codingKey.identifier),
                            )
                        )
                    }
                }
            )
        }
    }
}

private enum EncodableRequestMacroDiagnostic: String, DiagnosticMessage, Error {
    case typeAnnotationIsMandatory

    var message: String {
        switch self {
        case .typeAnnotationIsMandatory:
            "Type annotations are mandatory for stored properties of an encodable request"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "com.broadwaylamb.Hammond.\(Self.self)", id: rawValue)
    }

    var severity: DiagnosticSeverity {
        .error
    }
}

