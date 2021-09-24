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
    
    var uid: String                 //unique user identifier
    var name: String                //users name
    var email: String               //users email
    var phone: String               //users phone number
    var bio: String                 //biography for portfolio
    var gigs: Bool                  //musician = true, organiser = false
    var picURL: URL                 //profile image download URL
    private var facebook: String    //social link URLs...
    private var twitter: String
    private var instagram: String
    private var website: String
    private var appleMusic: String
    private var spotify: String
    private var fcmToken: String
    
    init(uid: String, name: String, email: String, phone: String, bio: String, gigs: Bool, picURL: URL, facebook: String, twitter: String, instagram: String, website: String, appleMusic: String, spotify: String, fcmToken: String) {
        self.uid = uid
        self.name = name
        self.email = email
        self.phone = phone
        self.bio = bio
        self.gigs = gigs
        self.picURL = picURL
        self.facebook = facebook
        self.twitter = twitter
        self.instagram = instagram
        self.website = website
        self.appleMusic = appleMusic
        self.spotify = spotify
        self.fcmToken = fcmToken
    }
    
    func getFacebook() -> String {
        return facebook
    }
    func getTwitter() -> String {
        return twitter
    }
    func getInstagram() -> String {
        return instagram
    }
    func getWebsite() -> String {
        return website
    }
    func getAppleMusic() -> String {
        return appleMusic
    }
    func getSpotify() -> String {
        return spotify
    }
    func getFCMToken() -> String {
        return fcmToken
    }
    
}

