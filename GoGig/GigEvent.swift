//
//  Event.swift
//  GoGig
//
//  Created by Lee Chilvers on 03/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation

class GigEvent {
    
    private var uid: String
    private var id: String
    private var title: String
    private var time: NSDate
    //private var location:
    private var postcode: String
    private var payment: Double
    private var name: String
    private var email: String
    private var phone: String
    private var eventPhotoURL: URL
    
    init(uid: String, id: String, title: String, time: NSDate, postcode: String, payment: Double, name: String, email: String, phone: String, eventPhotoURL: URL) {
        self.uid = uid
        self.id = id
        self.title = title
        self.time = time
        //self.location = location
        self.postcode = postcode
        self.payment = payment
        self.name = name
        self.email = email
        self.phone = phone
        self.eventPhotoURL = eventPhotoURL
    }
    
    func getuid() -> String {
        return uid
    }
    func getid() -> String {
        return id
    }
    func getTitle() -> String {
        return title
    }
    func getTime() -> NSDate {
        return time
    }
    //    func getLocation() -> ... {
    //        return location
    //    }
    func getPostcode() -> String {
        return postcode
    }
    func getPayment() -> Double {
        return payment
    }
    func getName() -> String {
        return name
    }
    func getEmail() -> String {
        return email
    }
    func getPhone() -> String {
        return phone
    }
    func getEventPhotoURL() -> URL {
        return eventPhotoURL
    }
}

