//
//  Bot+sendMessageEventAnswer.swift
//  
//
//  Created by Nickolay Truhin on 24.12.2020.
//

import Telegrammer
import Vkontakter
import Foundation

public extension Bot {
    
    enum SendMessageEventAnserError: Error {
        case botNotFound
        case destinationNotFound
    }
    
    /// Parameters container struct for `sendMessageEventAnswer` method
    struct SendMessageEventAnswerParams {

        /// Идентификатор события
        var eventId: String?
        
        var userId: Int64?
        
        var peerId: Int64?
        
        public enum `Type` {
            case notification(text: String, isAlert: Bool? = nil)
            case link(url: String)
            
            var vk: Vkontakter.EventData {
                switch self {
                case let .notification(text, _):
                    return .snackbar(.init(text: text))
                case let .link(url):
                    return .link(.init(link: url))
                }
            }
        }
        
        let type: Type
    
        func tg() throws -> Telegrammer.Bot.AnswerCallbackQueryParams {
            guard let eventId = eventId else { throw SendMessageEventAnserError.destinationNotFound }
            switch type {
            case let .notification(text, isAlert):
                return .init(callbackQueryId: eventId, text: text, showAlert: isAlert, url: nil, cacheTime: nil)
            case let .link(url):
                return .init(callbackQueryId: eventId, text: nil, showAlert: nil, url: url, cacheTime: nil)
            }
        }

        func vk() throws -> Vkontakter.Bot.SendMessageEventAnswerParams {
            guard let peerId = peerId, let eventId = eventId, let userId = userId else {
                throw SendMessageEventAnserError.destinationNotFound
            }
            return .init(eventId: eventId, userId: userId, peerId: peerId, eventData: type.vk)
        }
        
        var event: MessageEvent? {
            get {
                nil
            }
            set {
                self.eventId = newValue?.id
                self.userId = newValue?.fromId
                self.peerId = newValue?.peerId
            }
        }
        
        public init(event: MessageEvent? = nil, type: Bot.SendMessageEventAnswerParams.`Type`) {
            self.type = type
            self.event = event
        }
    }

    @discardableResult
    func sendMessageEventAnswer(_ params: SendMessageEventAnswerParams, platform: AnyPlatform) throws -> Future<Bool> {
        switch platform {
        case .vk:
            guard let vk = vk else { throw SendMessageEventAnserError.botNotFound }
            return try vk.sendMessageEventAnswer(params: try params.vk()).map { $0.bool }

        case .tg:
            guard let tg = tg else { throw SendMessageEventAnserError.botNotFound }
            return try tg.answerCallbackQuery(params: try params.tg())
        }
    }
}
