//
//  NeverCodable.swift
//  Hammond
//
//  Created by sergej on 04.07.2025.
//

/// `Swift.Never` conforms to `Encodable` or `Decodable` only since iOS 17
public enum NeverCodable: Codable {
    public func encode(to encoder: any Encoder) {
        switch self {
        }
    }

    public init(from decoder: any Decoder) throws {
        let context = DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Attempting to decode NeverCodable",
        )
        throw DecodingError.dataCorrupted(context)
    }
}
