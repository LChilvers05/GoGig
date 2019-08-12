//
//  Event.swift
//  GoGig
//
//  Created by Lee Chilvers on 03/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation
import CoreLocation

class GigEvent: Comparable {
    
    private var uid: String
    private var id: String
    private var title: String
    private var timestamp: String
    private var description: String
    private var latitude: Double
    private var longitude: Double
    private var distance: Double
    private var locationName: String
    private var postcode: String
    private var payment: Double
    private var name: String
    private var email: String
    private var phone: String
    private var eventPhotoURL: URL
    
    private var appliedUsers: [String: Bool]
    
    init(uid: String, id: String, title: String, timestamp: String, description: String, latitude: Double, longitude: Double, locationName: String, postcode: String, payment: Double, name: String, email: String, phone: String, eventPhotoURL: URL, appliedUsers: [String: Bool]) {
        self.uid = uid
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.description = description
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.postcode = postcode
        self.payment = payment
        self.name = name
        self.email = email
        self.phone = phone
        self.eventPhotoURL = eventPhotoURL
        self.distance = 0.00
        self.appliedUsers = appliedUsers
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
    func getTimestamp() -> String {
        return timestamp
    }
    func getDescription() -> String {
        return description
    }
    func getLocationName() -> String {
        return locationName
    }
    func getLatitude() -> Double {
        return latitude
    }
    func getLongitude() -> Double {
        return longitude
    }
    func getDistance() -> Double {
        return distance
    }
    func setDistance(distanceFromUser: Double) {
        self.distance = distanceFromUser
    }
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
    
    func getAppliedUsers() -> [String: Bool] {
        return appliedUsers
    }
    
    //MARK: timestamp string manipulation for date
    func getDayDate() -> String {
        return timestamp.substring(start: 8, end: 10)
    }
    func getMonthYearDate() -> String {
        return timestamp.substring(start: 0, end: 8)
    }
    func getTime() -> String {
        return timestamp.substring(start: 11, end: 16)
    }
    func getLongMonthYearDate() -> String {
        let month = getMonthYearDate().substring(start: 5, end: 7)
        let year = getMonthYearDate().substring(start: 0, end: 4)
        
        switch month {
        case "01":
            return "January " + year
        case "02":
            return "February " + year
        case "03":
            return "March " + year
        case "04":
            return "April " + year
        case "05":
            return "May " + year
        case "06":
            return "June " + year
        case "07":
            return "July " + year
        case "08":
            return "August " + year
        case "09":
            return "September " + year
        case "10":
            return "October " + year
        case "11":
            return "November" + year
        case" 12":
            return "December" + year
        default:
            return "error getting month"
        }
    }
    
    //MARK: get exact point location using the latitude and the longitude
    func getGigEventLocation() -> CLLocation {
        let gigEventLocation = CLLocation(latitude: latitude, longitude: longitude)
        return gigEventLocation
    }
    
    ///Quicksort based on location - nearest is first
    static func < (lhs: GigEvent, rhs: GigEvent) -> Bool {

        return lhs.getDistance() < rhs.getDistance()
    }
    
    static func == (lhs: GigEvent, rhs: GigEvent) -> Bool {
        return lhs.getDistance() == rhs.getDistance()
    }
}

