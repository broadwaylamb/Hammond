//
//  NeverEncodable.swift
//  Hammond
//
//  Created by sergej on 04.07.2025.
//

/// `Swift.Never` conforms to `Encodable` only since iOS 17
public enum NeverEncodable: Encodable {
    public func encode(to encoder: any Encoder) {
        switch self {
        }
    }
}
