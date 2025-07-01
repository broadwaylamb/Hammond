//
//  utils.swift
//  Hammond
//
//  Created by sergej on 01.07.2025.
//

import SwiftSyntax

extension AttributeSyntax {
    func getMacroArguments() -> [ExprSyntax] {
        guard let exprList = arguments?.as(LabeledExprListSyntax.self) else {
            return []
        }
        return exprList.map { $0.expression }
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
