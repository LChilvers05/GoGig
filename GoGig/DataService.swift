//
//  DataService.swift
//  GoGig
//
//  Created by Lee Chilvers on 27/01/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

let DB_BASE = Database.database().reference()
let ST_BASE = Storage.storage().reference()

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
    
    func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).child("auth").updateChildValues(userData)
    }
    
    func updateDBUserProfile(uid: String, userData: Dictionary<String, Any>){
        REF_USERS.child(uid).child("profile").updateChildValues(userData)
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
                                
                                let currentUserPicURL = URL(string: currentUserPicURLStr)
                                
                                //instansiate a new user object from the data grabbed
                                let currentUser = User(uid: uid, name: currentUserName, email: currentUserEmail, bio: currentUserBio, gigs: currentUserGigs, picURL: currentUserPicURL!)
                                
                                //return the user
                                handler(currentUser)
                            }
                        }
                    }
                }
            }
        })
    }
    
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
        REF_USERS.child(uid).child("posts").observe(.value, with: { (snapshot) in
            
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
    
    func updateDBEvents(uid: String, eventID: String, eventData: Dictionary<String, Any>){
        //We want to build an array of posts to grab and loop through in table view
        REF_EVENTS.child(eventID).updateChildValues(eventData)
    }
    
    func deleteDBEvents(uid: String, eventID: String){
        REF_EVENTS.child(eventID).removeValue()
    }
    
    //Return an array to loop through all the event objects
    func getDBEvents(uid: String, handler: @escaping (_ events: [GigEvent]) -> ()) {
        
        var gigEvents = [GigEvent]()
        
        //Grab the array full of events
        REF_EVENTS.observe(.value, with: { (snapshot) in
            
            //Grab an array of events in database
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                
                //Loop through them and grab data for instantiation
                for snap in snapshot {
                    
                    if let eventData = snap.value as? NSDictionary {
                        
                        if let eventID = eventData["eventID"] as? String {
                            if let eventTitle = eventData["title"] as? String {
                                if let timestamp = eventData["timestamp"] as? String {
                                    if let eventDescription = eventData["description"] as? String {
                                        if let eventPostcode = eventData["postcode"] as? String {
                                            if let eventPayment = eventData["payment"] as? Double {
                                                if let eventOrganiserUid = eventData["uid"] as? String {
                                                    if let eventName = eventData["name"] as? String {
                                                        if let eventEmail = eventData["email"] as? String {
                                                            if let eventPhone = eventData["phone"] as? String {
                                                                if let eventPhotoURLStr = eventData["eventPhotoURL"] as? String {
                                                                    
                                                                    let eventPhotoURL = URL(string: eventPhotoURLStr)

                                                                    let gigEvent = GigEvent(uid: eventOrganiserUid, id: eventID, title: eventTitle, timestamp: timestamp, description: eventDescription, postcode: eventPostcode, payment: eventPayment, name: eventName, email: eventEmail, phone: eventPhone, eventPhotoURL: eventPhotoURL!)
                                                                    
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
            //return it outside the list
            handler(gigEvents)
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
    
    
    
}

