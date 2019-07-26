//
//  ActivityNotification.swift
//  GoGig
//
//  Created by Lee Chilvers on 26/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation

class ActivityNotification {
    
    private var id: String
    private var type: String
    private var senderUid: String
    private var recieverUid: String
    private var senderName: String
    private var picURL: URL
    private var description: String
    private var time: NSDate
    
    init(id: String, type: String, senderUid: String, recieverUid: String, senderName: String, picURL: URL, description: String, time: NSDate) {
        self.id = id
        self.type = type
        self.senderUid = senderUid
        self.recieverUid = recieverUid
        self.senderName = senderName
        self.picURL = picURL
        self.description = description
        self.time = time
    }
    
    func getId() -> String {
        return id
    }
    func getType() -> String {
        return type
    }
    func getSenderUid() -> String {
        return senderUid
    }
    func getRecieverUid() -> String {
        return recieverUid
    }
    func getSenderName() -> String {
        return senderName
    }
    func getNotificationPicURL() -> URL {
        return picURL
    }
    func getNotificationDescription() -> String {
        return description
    }
    func getTime() -> NSDate {
        return time
    }
}
