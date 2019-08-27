//
//  User.swift
//  GoGig
//
//  Created by Lee Chilvers on 15/12/2018.
//  Copyright © 2018 ChillyDesigns. All rights reserved.
//

import Foundation

var uniqueID: String?

class User {
    
    //ref: MVC video, do we need private var??
    var uid: String
    var name: String
    var email: String
    var bio: String
    var gigs: Bool
    var picURL: URL
    private var fcmToken: String
    
    init(uid: String, name: String, email: String, bio: String, gigs: Bool, picURL: URL, fcmToken: String) {
        self.uid = uid
        self.name = name
        self.email = email
        self.bio = bio
        self.gigs = gigs
        self.picURL = picURL
        self.fcmToken = fcmToken
    }
    
    func getFCMToken() -> String {
        return fcmToken
    }
    
}

