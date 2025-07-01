//
//  utils.swift
//  Hammond
//
//  Created by sergej on 01.07.2025.
//

import SwiftSyntax
import SwiftSyntaxBuilder

extension AttributeSyntax {
    var macroName: String? {
        attributeName
            .as(IdentifierTypeSyntax.self)?
            .name
            .identifier?
            .name
    }

    func getMacroArguments() -> [ExprSyntax] {
        guard let exprList = arguments?.as(LabeledExprListSyntax.self) else {
            return []
        }
        return exprList.map { $0.expression }
    }

    func getMacroArgument(withLabel label: String) -> ExprSyntax? {
        guard let exprList = arguments?.as(LabeledExprListSyntax.self) else {
            return nil
        }
        return exprList.first { $0.label?.identifier?.name == label }?.expression
    }
}

extension VariableDeclSyntax {
    func getMacros(name: String) -> [AttributeSyntax] {
        attributes.compactMap {
            switch $0 {
            case .attribute(let attr):
                attr
            default:
                nil
            }
        }
    }
}

extension PatternBindingSyntax {
    var propertyName: String? {
        pattern.as(IdentifierPatternSyntax.self)?.identifier.text
    }
}

extension DeclGroupSyntax {
    var varDecls: [VariableDeclSyntax] {
        memberBlock
            .members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }
}

struct Lookahead<S: StringProtocol>: Sequence {
    fileprivate var string: S
    fileprivate var size: Int

    struct Iterator: IteratorProtocol {
        fileprivate var remaining: Substring
        fileprivate var size: Int

        mutating func next() -> Substring? {
            if remaining.isEmpty {
                return nil
            }
            let result = remaining.prefix(size)
            remaining = remaining.dropFirst()
            return result
        }
    }

    func makeIterator() -> Iterator {
        return Iterator(remaining: Substring(string), size: size)
    }
}

extension String {
    func lookahead(_ size: Int) -> Lookahead<String> {
        Lookahead(string: self, size: size)
    }
}

struct CodingKey {
    var key: ExprSyntax?
    var identifier: String
    var type: TypeSyntax
}

extension [CodingKey] {
    func generateCodingKeysEnum() throws -> EnumDeclSyntax {
        try EnumDeclSyntax("enum CodingKeys: String, CodingKey") {
            for codingKey in self {
                EnumCaseDeclSyntax {
                    EnumCaseElementSyntax(
                        name: .identifier(codingKey.identifier),
                        rawValue: codingKey.key.map {
                            InitializerClauseSyntax(value: $0)
                        }
                    )
                }
            }
        }
    }
}

func generateConformance(
    type: some TypeSyntaxProtocol,
    conformingTo protocols: [TypeSyntax],
    @MemberBlockItemListBuilder memberBlockBuilder: () throws -> MemberBlockItemListSyntax,
) rethrows -> [ExtensionDeclSyntax] {
    [
        try ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax {
                for `protocol` in protocols {
                    InheritedTypeSyntax(type: `protocol`)
                }
            },
            memberBlockBuilder: memberBlockBuilder,
        )
    ]
}
