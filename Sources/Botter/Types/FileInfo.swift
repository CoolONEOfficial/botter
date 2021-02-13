//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 11.01.2021.
//

import Foundation
import Telegrammer
import Vkontakter

public struct FileInfo: Codable {

    ///
    public enum `Type`: AutoCodable {
        case photo
        case document
    }

    public let type: `Type`
    
    ///
    public enum Content: AutoCodable {
        case fileId(BotterAttachable)
        case url(String)
        case file(InputFile)
        
        var tg: Telegrammer.FileInfo {
            switch self {
            case let .fileId(attachable):
                return .fileId(attachable.attachmentId)
            case let .url(url):
                return .url(url)
            case let .file(file):
                return .file(file.tg)
            }
        }
    }
    
    let content: Content
    
    public init(type: FileInfo.`Type`, content: FileInfo.Content) {
        self.type = type
        self.content = content
    }
    
    var vk: Vkontakter.Attachment? {
        guard case let .fileId(attachable) = content else { return nil }
        switch type {
        case .photo:
            guard let photo = Vkontakter.Photo(from: attachable.attachmentId) else { return nil }
            return .photo(photo)
        case .document:
            guard let doc = Vkontakter.Doc(from: attachable.attachmentId) else { return nil }
            return .doc(doc)
        }
    }
    
    func tgMedia(caption: String?) -> Telegrammer.InputMedia? {
        if case .file = content {
            debugPrint("files in groups not impletemnted yet")
            return nil
        }
        guard let mediaData = try? JSONEncoder().encode(content.tg),
              var media = String(data: mediaData, encoding: .utf8)?.trimmingCharacters(in: ["\""])
        else { return nil }
        media.removeAll(where: { $0 == "\\" })
        
        switch type {
        case .photo:
            return .inputMediaPhoto(.init(type: "photo", media: media, caption: caption, parseMode: nil))
        default:
            return nil
        }
    }
}

extension Telegrammer.InputMedia {
    var photoAndVideo: Telegrammer.InputMediaPhotoAndVideo? {
        switch self {
        case let .inputMediaPhoto(photo):
            return .inputMediaPhoto(photo)

        case let .inputMediaVideo(video):
            return .inputMediaVideo(video)

        default:
            return nil
        }
    }
}
