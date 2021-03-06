//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 13.12.2020.
//

import Foundation
import AnyCodable

// MARK: - Platform

public enum Platform<Tg: Codable, Vk: Codable> {
    case tg(Tg)
    case vk(Vk)
}

public extension Platform {
    var name: String {
        switch self {
        case .tg:
            return CodingKeys.tg.rawValue
        case .vk:
            return CodingKeys.vk.rawValue
        }
    }
    
    var any: AnyPlatform {
        convert(to: AnyCodable())
    }
    
    func same(_ platform: AnyPlatform) -> Bool {
        switch self {
        case .tg:
            if case .tg = platform {
                return true
            }
        case .vk:
            if case .vk = platform {
                return true
            }
        }
        return false
    }
}

extension Platform: CustomStringConvertible where Tg: CustomStringConvertible, Vk: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .tg(tg):
            return tg.description
        case let .vk(vk):
            return vk.description
        }
    }
}

public extension Array {
    func first<Tg, Vk>(for platform: AnyPlatform) -> Element? where Element == Platform<Tg, Vk> {
        first { $0.any == platform }
    }
    
    func firstValue<T>(for platform: AnyPlatform) -> T? where Element == TypedPlatform<T> {
        first(for: platform)?.value
    }
}

public extension Platform where Tg == Vk {
    var value: Tg {
        switch self {
        case let .tg(tg):
            return tg

        case let .vk(vk):
            return vk
        }
    }
}

extension Platform: Equatable where Tg: Equatable, Vk: Equatable {
    public static func == (lhs: Platform<Tg, Vk>, rhs: Platform<Tg, Vk>) -> Bool {
        switch lhs {
        case let .tg(tg):
            switch rhs {
            case let .tg(innerTg):
                return tg == innerTg
            case .vk:
                return false
            }
            
        case let .vk(vk):
            switch rhs {
            case .tg:
                return false
            case let .vk(innerVk):
                return vk == innerVk
            }
        }
    }
    
}

public extension Platform {
    func convert<T: Codable>(to value: T) -> Platform<T, T> {
        switch self {
        case .tg:
            return .tg(value)
        case .vk:
            return .vk(value)
        }
    }
}

extension Platform: Codable {

    enum CodingKeys: String, CodingKey {
        case tg
        case vk
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.allKeys.contains(.tg), try container.decodeNil(forKey: .tg) == false {
            let tg = try container.decode(Tg.self, forKey: .tg)
            self = .tg(tg)
            return
        }
        if container.allKeys.contains(.vk), try container.decodeNil(forKey: .vk) == false {
            let vk = try container.decode(Vk.self, forKey: .vk)
            self = .vk(vk)
            return
        }
        throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Unknown enum case"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .tg(tg):
            try container.encode(tg, forKey: .tg)

        case let .vk(vk):
            try container.encode(vk, forKey: .vk)
        }
    }

}

extension Platform: Hashable where Tg: Hashable, Vk: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .tg(tg):
            hasher.combine(tg)

        case let .vk(vk):
            hasher.combine(vk)
        }
    }
}

// MARK: - AnyPlatform

public typealias AnyPlatform = Platform<AnyCodable, AnyCodable>

public extension AnyPlatform {
    static let tg: Self = .tg(.init())
    static let vk: Self = .vk(.init())
}

public extension Array where Element == AnyPlatform {
    static let all: Self = [ .vk, .tg ]
    
    static func available(bot: Bot) -> Self {
        var platforms = Self()
        
        if bot.vk != nil {
            platforms.append(.vk)
        }
        
        if bot.tg != nil {
            platforms.append(.tg)
        }
        
        return platforms
    }
}

// MARK: - Typed platform

public typealias TypedPlatform<T: Codable> = Platform<T, T>
