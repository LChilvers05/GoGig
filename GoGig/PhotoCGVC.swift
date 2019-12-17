//
//  PhotoCGVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 18/06/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class PhotoCGVC: UIViewController {
    
    @IBOutlet weak var eventPicView: UIImageView!
    let loadingSpinner = SpinnerViewController()
    
    var editingGate = true
    var gigEvent: GigEvent?
    var user: User?
    var eventData: Dictionary<String, Any>?
    var notificationData: Dictionary<String, Any>?
    
    var imagePicker: UIImagePickerController?
    
    var eventID = ""
    var imageID = ""
    var imageAdded = false
    var imageContent: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //if editing
        if editingGigEvent && editingGate && gigEvent != nil {
            //get the event image id
            imageID = "\(gigEvent!.getid()).jpg"
            //download the image and put it in the view to preview
            downloadImage(url: gigEvent!.getEventPhotoURL()) { (returnedImage) in
                self.eventPicView.image = returnedImage
                self.imageAdded = true
            }
            //so does not download again when view appears
            editingGate = false
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        //allow user to choose an image (camera or library)
        openPhotoPopup(video: false, imagePicker: imagePicker!, title: "Event", message: "Take or choose a photo of the event venue")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            
            eventPicView.image = selectedImage
            
            //returned image
            imageContent = selectedImage
            //set as one added
            imageAdded = true
            
            //give the image a new ID if creating event
            if !editingGigEvent {
                imageID = "\(NSUUID().uuidString).jpg"
            }
        }
        //dismiss the image picker
        dismiss(animated: true, completion: nil)
    }
    
    func picUpload(uid: String, handler: @escaping (_ url: URL) -> ()) {
        
        //delete the old event photo from Storage if editing
        if editingGigEvent && gigEvent != nil {
            DataService.instance.deleteSTFile(uid: user!.uid, directory: "events", fileID: gigEvent!.getid()) //efficient Storage usage
        }
        //upload the photo
        if let eventPic = eventPicView.image {
            
            DataService.instance.updateSTPic(uid: uid, directory: "events", imageContent: eventPic, imageID: imageID, uploadComplete: { (success, error) in
                if error != nil {
                    //allow user to interact with screen again if error
                    self.removeSpinnerView(self.loadingSpinner)
                    self.displayError(title: "There was an Error", message: error!.localizedDescription)
                    
                } else {
                    //get the download URL
                    DataService.instance.getSTURL(uid: uid, directory: "events", imageID: self.imageID) { (returnedURL) in
                        //return it
                        handler(returnedURL)
                    }
                }
            })
        }
    }
    
    @IBAction func postEvent(_ sender: Any) {
        //check image has been added
        if imageAdded {
            
            let range = imageID.index(imageID.endIndex, offsetBy: -4)..<imageID.endIndex
            imageID.removeSubrange(range)//'remove the .jpg from the imageID
            
            //eventID needed for deletion
            eventID = imageID
            //add id to dictionary
            eventData!["eventID"] = eventID
            //stop user interaction with screen (show uploading)
            createSpinnerView(loadingSpinner)
            //upload the picture
            self.picUpload(uid: user!.uid) {
                (returnedURL) in
                //add photo url to dictionary
                self.eventData!["eventPhotoURL"] = returnedURL.absoluteString
                //start a dictionary to keep track of musicians applied to the event
                self.eventData!["appliedUsers"] = ["CREATOR:\(self.user!.uid)": true]
                
                //create an event object in Database
                DataService.instance.updateDBEvents(uid: self.user!.uid, eventID: self.eventID, eventData: self.eventData!)
                
                //add the event under user to the database
                //no need to update if the user is editing, otherwise we get a duplicate
                if !editingGigEvent {
                    DataService.instance.updateDBUserEvents(uid: self.user!.uid, eventID: self.eventID)
                }
                
                if !editingGigEvent {
                    self.updateActivity()
                    
                    //update the activity feed in a completion handler so it updates correctly
                    DataService.instance.updateDBActivityFeed(uid: self.notificationData!["reciever"] as! String, notificationID: self.notificationData!["notificationID"] as! String, notificationData: self.notificationData!) { (complete) in
                        
                        if complete {
                            self.removeSpinnerView(self.loadingSpinner)
                            //take user to Activity tab to see their posted event
                            //without completion handler we were jumping to the view controller before the activity had updated
                            self.tabBarController?.selectedIndex = 2
                            
                            //clear the event creation and pop to root of the navigation stack
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                } else {
                    //if editing only
                    self.removeSpinnerView(self.loadingSpinner)
                    //clear the event creation and pop to root of the navigation stack (which is the EventDescriptionVC this time)
                    self.navigationController?.popToRootViewController(animated: true)
                    //done editing
                    editingGigEvent = false
                    //show the new event features in the activity feed
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshAllActivity"), object: nil)
                }
            }
        } else {
            
            displayError(title: "Oops", message: "Please take or add a photo of the venue to post event")
        }
    }
    
    //create dictionary for activity notification
    func updateActivity() {
        let notificationID = NSUUID().uuidString
        let senderUid = user!.uid
        //receiver is also the sender for a personal notification
        let recieverUid = senderUid
        let senderName = "You"
        //users profile picture
        let notificationPicURL = user!.picURL.absoluteString
        let notificationDescription = "Created the event: \((eventData!["title"])!)"
        //timestamp for quicksort
        let timestamp = NSDate().timeIntervalSince1970
        notificationData = ["notificationID": notificationID, "relatedEventID": eventID, "type": "personal", "sender": senderUid, "reciever": recieverUid, "senderName": senderName, "picURL": notificationPicURL, "description": notificationDescription, "timestamp": timestamp]
    }
}

