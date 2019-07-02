//
//  ChatRoom.swift
//  FirebaseChatHW
//
//  Created by Michael Flowers on 7/2/19.
//  Copyright © 2019 Michael Flowers. All rights reserved.
//

import Foundation
import MessageKit

struct ChatRoom: Codable, Equatable {
    let title: String
    var messages: [ChatRoom.Message]
    let identifier: String
    
    init(title: String, messages: [ChatRoom.Message] = [], identifier: String = UUID().uuidString){
        self.title = title
        self.messages = messages
        self.identifier = identifier
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let title = try container.decode(String.self, forKey: .title)
        let identifier = try container.decode(String.self, forKey: .identifier)
        if let messages = try container.decodeIfPresent([String : Message].self, forKey: .messages) {
            self.messages = Array(messages.values)
        } else {
            self.messages = []
        }
        self.title = title
        self.identifier = identifier
    }
    
    //per the messageKit document MessageType is a protocol that we can use to merge our code with
    struct Message: Codable, Equatable, MessageType {
        let text: String
        let timestamp: Date
        let displayName: String
        
        //properties to g with the messageKit
        let senderID: String
        let messageId: String
        var sentDate: Date { return timestamp } //we are initializing timestamp so we don't have to initialize sentDate
        var kind: MessageKind { return .text(text) } //we are initializing text so we don't have to initialize kind
        var sender: SenderType { return Sender(senderId: senderID, displayName: displayName) }
        
        init(text: String, sender: Sender, timestamp: Date = Date(), messageId: String = UUID().uuidString){
            //we are just using the sender once because it's a struct that has two properties we can set with it
            self.text = text
            self.displayName = sender.displayName
            self.timestamp = timestamp
            self.senderID = sender.senderId
            self.messageId = messageId
        }
        
        enum CodingKeys: String, CodingKey {
            case displayName
            case senderID
            case text
            case timestamp
        }
        
        //create a message from a decoder
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let text = try container.decode(String.self, forKey: .text)
            let displayName = try container.decode(String.self, forKey: .displayName)
            let senderID = try container.decode(String.self, forKey: .senderID)
            let timestamp = try container.decode(Date.self, forKey: .timestamp)
            
            let sender = Sender(senderId: senderID, displayName: displayName)
            
            //initialize all of the properties in the enum
            self.init(text: text, sender: sender, timestamp: timestamp)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(displayName, forKey: .displayName)
            try container.encode(senderID, forKey: .senderID)
            try container.encode(timestamp, forKey: .timestamp)
            try container.encode(text, forKey: .text)
        }
    }
    static func ==(lhs: ChatRoom, rhs: ChatRoom) -> Bool {
        return lhs.title == rhs.title &&
            lhs.identifier == rhs.identifier &&
            lhs.messages == rhs.messages
    }
}
struct Sender: SenderType {
    var senderId: String
    var displayName: String
}


