//
//  DataService.swift
//  GoGig
//
//  Created by Lee Chilvers on 27/01/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

let DB_BASE = Database.database().reference()
let ST_BASE = Storage.storage().reference()

var postsHandle: DatabaseHandle?
var activityHandle: DatabaseHandle?
var eventsHandle: DatabaseHandle?

class DataService {
    
    static let instance = DataService()
    
    //MARK: DATABASE
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_EVENTS = DB_BASE.child("events")
    
    var REF_BASE: DatabaseReference {
        
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        
        return _REF_USERS
    }
    
    var REF_EVENTS: DatabaseReference {
        
        return _REF_EVENTS
    }
    
    //MARK: OBSERVERS
    
    func removeObservers(uid: String) {
        REF_USERS.child(uid).child("posts").removeObserver(withHandle: postsHandle!)
        if eventsHandle != nil && activityHandle != nil {
            print("handle reached")
            REF_USERS.child(uid).child("events").removeObserver(withHandle: eventsHandle!)
            REF_USERS.child(uid).child("activity").removeObserver(withHandle: activityHandle!)
        }
    }
    
    //MARK: DATABASE USER PROFILE
    
    func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).child("auth").updateChildValues(userData)
    }
    
    func updateDBUserProfile(uid: String, userData: Dictionary<String, Any>, handler: @escaping (_ completion: Bool) -> ()) {
        REF_USERS.child(uid).child("profile").updateChildValues(userData) {
            (error:Error?, ref:DatabaseReference) in
            if error != nil {
                handler(false)
            } else {
                handler(true)
            }
        }
    }
    
    func getDBUserProfile(uid: String, handler: @escaping (_ user: User) -> ()) {
        
        //Grab user profile data from the database...
        REF_USERS.child(uid).child("profile").observeSingleEvent(of: .value, with: { (profileSnapshot) in
            
            //... and cast as a NSDictionary
            let profileData = profileSnapshot.value as? NSDictionary
            if let currentUserName = profileData?["name"] as? String {
                if let currentUserEmail = profileData?["email"] as? String {
                    if let currentUserGigs = profileData?["gigs"] as? Bool {
                        if let currentUserBio = profileData?["bio"] as? String {
                            if let currentUserPicURLStr = profileData?["picURL"] as? String {
                                
                                if let currentUserPhone = profileData?["phone"] as? String {
                                    if let currentUserFacebook = profileData?["facebook"] as? String {
                                        if let currentUserTwitter = profileData?["twitter"] as? String {
                                            if let currentUserInstagram = profileData?["instagram"] as? String {
                                                if let currentUserWebsiteURLStr = profileData?["website"] as? String {
                                                    if let currentUserAppleMusicURLStr = profileData?["appleMusic"] as? String {
                                                        if let currentUserSpotifyURLStr = profileData?["spotify"] as? String {
                                                            

                                                            let currentUserPicURL = URL(string: currentUserPicURLStr)
                                                            
                                                            guard let currentUserFCMToken = profileData?["FCMToken"] as? String else { return }
                                                            
                                                            
                                                            //instansiate a new user object from the data grabbed
                                                            let currentUser = User(uid: uid, name: currentUserName, email: currentUserEmail, phone: currentUserPhone, bio: currentUserBio, gigs: currentUserGigs, picURL: currentUserPicURL!, facebook: currentUserFacebook, twitter: currentUserTwitter, instagram: currentUserInstagram, website: currentUserWebsiteURLStr, appleMusic: currentUserAppleMusicURLStr, spotify: currentUserSpotifyURLStr, fcmToken: currentUserFCMToken)
                                                            
                                                            //return the user
                                                            handler(currentUser)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }) { (error) in
            print("Error Getting user profile")
            print(error.localizedDescription)
        }
    }
    
    //MARK: DATABASE USER PORTFOLIO POSTS
    
    func updateDBPortfolioPosts(uid: String, postID: String, postData: Dictionary<String, Any>){
        //We want to build an array of posts to grab and loop through in table view
        REF_USERS.child(uid).child("posts").child(postID).updateChildValues(postData)
    }
    
    //we now store the postID in the database as well
    func deleteDBPortfolioPosts(uid: String, postID: String){
        REF_USERS.child(uid).child("posts").child(postID).removeValue()
    }
    
    //We're going to return an array to loop through full of post objects
    func getDBPortfolioPosts(uid: String, handler: @escaping (_ posts: [PortfolioPost]) -> ()) {
        
        var porfolioPosts = [PortfolioPost]()
        
        //Grab the array full of posts
        postsHandle = REF_USERS.child(uid).child("posts").observe(.value, with: { (snapshot) in
            
            //Grab an array of all posts in the database
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                //Loop through them and grab data for instantiation
                for snap in snapshot {
                    
                    if let postData = snap.value as? NSDictionary {
                        
                        if let postID = postData["postID"] as? String {
                            
                            if let postURLStr = postData["postURL"] as? String {
                                if let thumbnailURLStr = postData["thumbnailURL"] as? String {
                                    if let timeInterval = postData["timestamp"] as? TimeInterval {
                                        if let postIsImage = postData["isImage"] as? Bool {
                                            if let postCaption = postData["caption"] as? String {
                                                if let postLocation = postData["location"] as? String {
                                                    if let postDimensions = postData["dimensions"] as? Dictionary<String, Any> {
                                                        
                                                        let postURL = URL(string: postURLStr)
                                                        var thumbnailURL = postURL
                                                        //Check it has a thumbnail
                                                        if let tURL = URL(string: thumbnailURLStr) {
                                                            thumbnailURL = tURL
                                                        }
                                                        
                                                        //Convert time to NSDate
                                                        let postTime = NSDate(timeIntervalSince1970: timeInterval)
                                                        
                                                        let post = PortfolioPost(uid: uid, id: postID, location: postLocation, caption: postCaption, isImage: postIsImage, postURL: postURL!, thumbnailURL: thumbnailURL!, time: postTime, dimensions: postDimensions)
                                                        
                                                        porfolioPosts.append(post)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //return it outside the list
            handler(porfolioPosts)
        })
    }
    
    //MARK: DATABASE EVENTS
    
    func updateDBEvents(uid: String, eventID: String, eventData: Dictionary<String, Any>){
        //We want to build an array of posts to grab and loop through in table view
        REF_EVENTS.child(eventID).updateChildValues(eventData)
    }
    
    func updateDBEventsInteractedUsers(uid: String, eventID: String, eventData: Dictionary<String, Bool>){
        
        //Set Value because we are updating a new array with all the interacted users, therefore we want the array to replace each time, not update
        REF_EVENTS.child(eventID).child("appliedUsers").setValue(eventData)
    }
    
    //TODO: delete an event if after refresh the timestamp is less than the current date and time (not relevant)
    func deleteDBEvents(uid: String, eventID: String){
        REF_EVENTS.child(eventID).removeValue()
    }
    
    //Return an array to loop through all the event objects
    func getDBEvents(uid: String, handler: @escaping (_ events: [GigEvent]) -> ()) {
        
        var gigEvents = [GigEvent]()
        
        //Grab the array full of events
        REF_EVENTS.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Grab an array of events in database
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                //Loop through them and grab data for instantiation
                for snap in snapshot {
                    
                    if let eventData = snap.value as? NSDictionary {
                        
                        if let appliedUsers = eventData["appliedUsers"] as? [String: Bool] {
                            if self.checkAppliedUsers(appliedUsers: appliedUsers) {
                                
                                if let eventID = eventData["eventID"] as? String {
                                    if let eventTitle = eventData["title"] as? String {
                                        if let timestamp = eventData["timestamp"] as? String {
                                            if let eventDescription = eventData["description"] as? String {
                                                
                                                //
                                                if let eventLatitude = eventData["latitude"] as? Double {
                                                    if let eventLongitude = eventData["longitude"] as? Double {
                                                        if let eventLocationName = eventData["locationName"] as? String {
                                                        
                                                            if let eventPostcode = eventData["postcode"] as? String {
                                                                if let eventPayment = eventData["payment"] as? Double {
                                                                    if let eventOrganiserUid = eventData["uid"] as? String {
                                                                        if let eventName = eventData["name"] as? String {
                                                                            if let eventEmail = eventData["email"] as? String {
                                                                                if let eventPhone = eventData["phone"] as? String {
                                                                                    if let eventPhotoURLStr = eventData["eventPhotoURL"] as? String {
                                                                                    
                                                                                        let eventPhotoURL = URL(string: eventPhotoURLStr)

                                                                                        let gigEvent = GigEvent(uid: eventOrganiserUid, id: eventID, title: eventTitle, timestamp: timestamp, description: eventDescription, latitude: eventLatitude, longitude: eventLongitude, locationName: eventLocationName, postcode: eventPostcode, payment: eventPayment, name: eventName, email: eventEmail, phone: eventPhone, eventPhotoURL: eventPhotoURL!, appliedUsers: appliedUsers)
                                                                                    
                                                                                        gigEvents.append(gigEvent)
                                                                                        
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //return it outside the list
            handler(gigEvents)
        })
    }
    
    //So that the same gig doesn't appear twice to a musician that has already seen it
    func checkAppliedUsers(appliedUsers: [String: Bool]) -> Bool {
        
        for (uid, _) in appliedUsers {
            if uid == Auth.auth().currentUser?.uid {
                
                print("denied access to gig")
                return false
            }
        }
        
        print("granted access to gig")
        return true
    }
    
    //Get a single GigEvent upon request rather than array of GigEvents
    func getDBSingleEvent(uid: String, eventID: String, handler: @escaping (_ events: GigEvent) -> ()) {
        
        REF_EVENTS.child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in

            if let eventData = snapshot.value as? NSDictionary {
                
                if let appliedUsers = eventData["appliedUsers"] as? [String: Bool] {
                    if let eventID = eventData["eventID"] as? String {
                        if let eventTitle = eventData["title"] as? String {
                            if let timestamp = eventData["timestamp"] as? String {
                                if let eventDescription = eventData["description"] as? String {
                                    
                                    if let eventLatitude = eventData["latitude"] as? Double {
                                        if let eventLongitude = eventData["longitude"] as? Double {
                                            if let eventLocationName = eventData["locationName"] as? String {
                                            
                                                if let eventPostcode = eventData["postcode"] as? String {
                                                    if let eventPayment = eventData["payment"] as? Double {
                                                        if let eventOrganiserUid = eventData["uid"] as? String {
                                                            if let eventName = eventData["name"] as? String {
                                                                if let eventEmail = eventData["email"] as? String {
                                                                    if let eventPhone = eventData["phone"] as? String {
                                                                        if let eventPhotoURLStr = eventData["eventPhotoURL"] as? String {
                                                                            
                                                                            let eventPhotoURL = URL(string: eventPhotoURLStr)
                                                                            
                                                                            let gigEvent = GigEvent(uid: eventOrganiserUid, id: eventID, title: eventTitle, timestamp: timestamp, description: eventDescription, latitude: eventLatitude, longitude: eventLongitude, locationName: eventLocationName, postcode: eventPostcode, payment: eventPayment, name: eventName, email: eventEmail, phone: eventPhone, eventPhotoURL: eventPhotoURL!, appliedUsers: appliedUsers)
                                                                            
                                                                            handler(gigEvent)
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    //MARK: USERS EVENTS
    
    //Simply keep record of which events this user has interacted with to list in the 'My Events' section
    func updateDBUserEvents(uid: String, eventID: String) {
        //Get the current array of user's events
        //And append to it to update the database with
        getDBUserEvents(uid: uid) { (returnedEvents) in
            var recordedEvents = returnedEvents
            //recordedEvents.insert(eventID, at: 0)
            recordedEvents.append(eventID)
            
            self.REF_USERS.child(uid).child("events").setValue(recordedEvents)
        }
    }
    //We delete by updating with a new array without the value to be deleted
    func deleteDBUserEvents(uid: String, eventIDs: [String]) {
        self.REF_USERS.child(uid).child("events").setValue(eventIDs)
    }
    func getDBUserEvents(uid: String, handler: @escaping (_ events: [String]) -> ()) {
        
        var recordedEvents = [String]()
        
        //Grab the array full of events
        REF_USERS.child(uid).child("events").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                for snap in snapshot {
                    
                    if let recordedEvent = snap.value as? String {
                        recordedEvents.insert(recordedEvent, at: 0)
                    }
                }
            }
            handler(recordedEvents)
        })
    }
    
//    //To observe when an event recording is added under user in DB
//    func observeDBUserEvents(uid: String, handler: @escaping (_ events: String) -> ()) {
//
//        eventsHandle = REF_USERS.child(uid).child("events").observe(.childAdded, with: { (snapshot) in
//
//            if let recordedEvent = snapshot.value as? String {
//                print(recordedEvent)
//                handler(recordedEvent)
//            }
//        })
//    }
    
    //MARK: DATABASE USER ACTIVITY
    
    //Using a completion handler now so the feed updates correctly
    func updateDBActivityFeed(uid: String, notificationID: String, notificationData: Dictionary<String, Any>, handler: @escaping (_ completion: Bool) -> ()) {
        
        REF_USERS.child(uid).child("activity").child(notificationID).setValue(notificationData) {
            (error:Error?, ref:DatabaseReference) in
            if error != nil {
                handler(false)
            } else {
                handler(true)
            }
        }
    }
    
    func deleteDBActivityFeed(uid: String, notificationID: String) {
        
        REF_USERS.child(uid).child("activity").child(notificationID).removeValue()
    }
    
    func getDBActivityFeed(uid: String, currentActivity: [ActivityNotification], handler: @escaping (_ events: [ActivityNotification]) -> ()) {
        print(currentActivity)
        let lastActivity = currentActivity.last
        var queryRef: DatabaseQuery
        
        if lastActivity == nil || paginationGateOpen {
            //Needed as doesn't refresh properly on sign in and sign out, fetches incorrect starting 10
            paginationGateOpen = false
            //Fetch first 10 if the initial query
            queryRef = REF_USERS.child(uid).child("activity").queryOrdered(byChild: "timestamp").queryLimited(toLast: 10)
        } else {
            let lastTimestamp = lastActivity?.getTime().timeIntervalSince1970
            //fetch another 10 starting at the last one in the array, progressing another 10
            queryRef = REF_USERS.child(uid).child("activity").queryOrdered(byChild: "timestamp").queryEnding(atValue: lastTimestamp).queryLimited(toLast: 10)
        }
        
        //This contents of this array is appended when returned to display in table
        var activityNotifications = [ActivityNotification]()
        
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Grab an array of all posts in the database
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                //Loop through them and grab data for instantiation
                for snap in snapshot {
                    
                    if let activityData = snap.value as? NSDictionary {
                        
                        if let notificationID = activityData["notificationID"] as? String {
                            
                            if notificationID != lastActivity?.getId() {
                                
                                if let relatedEventID = activityData["relatedEventID"] as? String {
                                    if let notificationType = activityData["type"] as? String {
                                        if let senderUid = activityData["sender"] as? String {
                                            if let recieverUid = activityData["reciever"] as? String {
                                                if let senderName = activityData["senderName"] as? String {
                                                    if let notificationPhotoURLStr = activityData["picURL"] as? String {
                                                        if let notificationDescription = activityData["description"] as? String {
                                                            if let timeInterval = activityData["timestamp"] as? TimeInterval {
                                                                
                                                                let notificationPhotoURL = URL(string: notificationPhotoURLStr)
                                                                
                                                                let notificationTime = NSDate(timeIntervalSince1970: timeInterval)
                                                                
                                                                let activityNotification = ActivityNotification(id: notificationID, relatedEventId: relatedEventID, type: notificationType, senderUid: senderUid, recieverUid: recieverUid, senderName: senderName, picURL: notificationPhotoURL!, description: notificationDescription, time: notificationTime)
                                                                
                                                                //Insert at 0 (not append) to be in correct order
                                                                activityNotifications.insert(activityNotification, at: 0)

                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
                
            handler(activityNotifications)
        })
    }
    
    func observeDBActivityFeed(uid: String, handler: @escaping (_ events: ActivityNotification) -> ()) {

        activityHandle = REF_USERS.child(uid).child("activity").observe(.childAdded, with: { (snapshot) in

            //Grab an array of all posts in the database
            if let activityData = snapshot.value as? NSDictionary {

                if let notificationID = activityData["notificationID"] as? String {
                    if let relatedEventID = activityData["relatedEventID"] as? String {
                        if let notificationType = activityData["type"] as? String {
                            if let senderUid = activityData["sender"] as? String {
                                if let recieverUid = activityData["reciever"] as? String {
                                    if let senderName = activityData["senderName"] as? String {
                                        if let notificationPhotoURLStr = activityData["picURL"] as? String {
                                            if let notificationDescription = activityData["description"] as? String {
                                                if let timeInterval = activityData["timestamp"] as? TimeInterval {

                                                    let notificationPhotoURL = URL(string: notificationPhotoURLStr)

                                                    let notificationTime = NSDate(timeIntervalSince1970: timeInterval)

                                                    let activityNotification = ActivityNotification(id: notificationID, relatedEventId: relatedEventID, type: notificationType, senderUid: senderUid, recieverUid: recieverUid, senderName: senderName, picURL: notificationPhotoURL!, description: notificationDescription, time: notificationTime)

                                                    handler(activityNotification)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    //MARK: CLOUD STORAGE
    
    private var _REF_ST = ST_BASE
    
    var REF_ST: StorageReference {
        
        return _REF_ST
    }
    
    func updateSTPic(uid: String, directory: String, imageContent: UIImage, imageID: String, uploadComplete: @escaping ( _ status: Bool, _ error: Error?) -> ()) {
        
        //Converting the imageData to JPEG to be stored
        if let imageData = imageContent.jpegData(compressionQuality: 0.1) {
            
            //Uploading the image with unique string ID
            REF_ST.child(uid).child(directory).child(imageID).putData(imageData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    
                    uploadComplete(false, error)
                    return
                }
                uploadComplete(true, nil)
            })
        }
    }
    
    func updateSTVid(uid: String, directory: String, vidContent: URL, imageID: String, uploadComplete: @escaping ( _ status: Bool, _ error: Error?) -> ()) {
        //Uploading the content with unique string ID
        
        //This time we use .putFile to upload the URL and not imageData
        REF_ST.child(uid).child(directory).child(imageID).putFile(from: vidContent, metadata: nil, completion: { (metadata, error) in
            if error != nil {
                
                uploadComplete(false, error)
                return
            }
            uploadComplete(true, nil)
        })
    }
    
    //Now do user caching
    
    func getSTURL(uid: String, directory: String, imageID: String, handler: @escaping (_ returnedURL: URL) -> ()) {
        
        //Reference to the folder
        let ref = REF_ST.child(uid).child(directory).child(imageID)
        
        //Get's the url of the profile pic
        ref.downloadURL(completion: { (url, error) in
            if error != nil {
                
                
                print("Couldn't get imageURL \(error!.localizedDescription)")
                
            } else {
                
                handler(url!)
                
            }
        })
    }
    
    func deleteSTFile(uid: String, directory: String, fileID: String){
        REF_ST.child(uid).child(directory).child(fileID).delete(completion: { error in
            if error != nil {
            
                print("Couldn't delete image from ST \(error!.localizedDescription)")
                
            }
        })
    }
    
    
    //    func updateSTProfilePic(uid: String, profileImage: UIImage, imageID: String, uploadComplete: @escaping ( _ status: Bool, _ error: Error?) -> ()) {
    //
    //        //Converting the imageData to JPEG to be stored
    //        if let imageData = profileImage.jpegData(compressionQuality: 0.1) {
    //
    //            //Uploading the image with unique string ID
    //            REF_ST.child(uid).child("profilePic").child(imageID).putData(imageData, metadata: nil, completion: { (metadata, error) in
    //                if error != nil {
    //
    //                    uploadComplete(false, error)
    //                    return
    //                }
    //                uploadComplete(true, nil)
    //            })
    //        }
    //    }
    //
    //    func updateSTPostPic(uid: String, postImage: UIImage, imageID: String, uploadComplete: @escaping ( _ status: Bool, _ error: Error?) -> ()) {
    //
    //        //Converting the imageData to JPEG to be stored
    //        if let imageData = postImage.jpegData(compressionQuality: 0.1) {
    //
    //            //Uploading the image with unique string ID
    //            REF_ST.child(uid).child("portfolioPost").child(imageID).putData(imageData, metadata: nil, completion: { (metadata, error) in
    //                if error != nil {
    //
    //                    uploadComplete(false, error)
    //                    return
    //                }
    //                uploadComplete(true, nil)
    //            })
    //        }
    //    }
    
    
    //MARK: CLOUD MESSAGING
    //(and database)
    
    func updateDBUserFCMToken(uid: String, token: String) {
        REF_USERS.child(uid).child("profile").child("FCMToken").setValue(token)
    }
    
    //Send a notification from a device to another device
    func sendPushNotification(to token: String, title: String, body: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : "test_id"]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAjb8BHzs:APA91bEBkZ3IfE6dU4xclXlP4qGVqyFhMLQEuCTA8NtFjKC7WGN_L8LeuaH_t7142RWGLbuYqjSHozuiz7HtmAADhGEz67yMOjN416Z-EdbIE9FXJ-0uyI37mcQ6bcMzbohxSzF4nCUJ", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
    
    //FCM Server key: AAAAjb8BHzs:APA91bEBkZ3IfE6dU4xclXlP4qGVqyFhMLQEuCTA8NtFjKC7WGN_L8LeuaH_t7142RWGLbuYqjSHozuiz7HtmAADhGEz67yMOjN416Z-EdbIE9FXJ-0uyI37mcQ6bcMzbohxSzF4nCUJ
}

