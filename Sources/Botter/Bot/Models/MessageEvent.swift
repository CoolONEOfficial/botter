//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 21.12.2020.
//

import Foundation
import Vkontakter
import Telegrammer
import AnyCodable

public struct MessageEvent {

    public let id: String

    public let data: AnyCodable

    public var peerId: Int64?

    public var fromId: Int64?

    public let platform: Platform<Tg, Vk>

    public func decodeData<T: Decodable>(decoder: JSONDecoder = .snakeCased) throws -> T {
        try decoder.decode(T.self, from: JSONSerialization.data(withJSONObject: data.value))
    }

}

extension MessageEvent: PlatformObject {
    
    public typealias Tg = Telegrammer.CallbackQuery
    public typealias Vk = Vkontakter.MessageEvent
    
    init?(from tg: Tg) {
        platform = .tg(tg)

        id = tg.id
        peerId = tg.from.id
        fromId = tg.from.id
        guard let data = tg.data?.data(using: .utf8) else { return nil }
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
            self.data = .init(jsonObject)
        } else {
            self.data = .init(data)
        }
    }

    init?(from vk: Vk) {
        platform = .vk(vk)
        
        id = vk.eventId
        peerId = vk.peerId
        fromId = vk.userId
        guard let data = vk.payload else { return nil }
        if let str = data.value as? String {
            self.data = .init(str.data(using: .utf8))
        } else {
            self.data = data
        }
    }
    
}
