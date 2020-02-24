//
//  ActivityNotification.swift
//  GoGig
//
//  Created by Lee Chilvers on 26/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation

class ActivityNotification: Comparable {
    
    private var id: String              //unique id of notification
    private var relatedEventId: String  //event notification concerns
    private var type: String            //personal, applied or reply
    private var senderUid: String       //user id of notification sender
    private var recieverUid: String     //user id of notification receiver
    private var senderName: String      //senders account name
    private var picURL: URL             //notification image download URL
    private var description: String     //contents of the notification
    private var time: NSDate            //to sort in reverse chronological order
    //instantiate a ActivityNotification object
    init(id: String, relatedEventId: String, type: String, senderUid: String, recieverUid: String, senderName: String, picURL: URL, description: String, time: NSDate) {
        self.id = id
        self.relatedEventId = relatedEventId
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
    func getRelatedEventId() -> String {
        return relatedEventId
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
    
    //quicksort to most recent notification first (based from timestamp)
    static func < (lhs: ActivityNotification, rhs: ActivityNotification) -> Bool {
        //inverse so that quick sort of feed shows most recent first
        return rhs.getTime().compare(lhs.getTime() as Date) == .orderedAscending
    }
    
    static func == (lhs: ActivityNotification, rhs: ActivityNotification) -> Bool {
        return lhs.getTime() == rhs.getTime() || lhs.getTime().compare(rhs.getTime() as Date) == .orderedSame
    }
}
