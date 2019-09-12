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
        setupCGView()
        setupView()
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if editingGigEvent && editingGate && gigEvent != nil {
            imageID = "\(gigEvent!.getid()).jpg"
            downloadImage(url: gigEvent!.getEventPhotoURL()) { (returnedImage) in
                self.eventPicView.image = returnedImage
            }
            editingGate = false
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        openPhotoPopup(video: false, imagePicker: imagePicker!, title: "Event", message: "Take or choose a photo of the event venue")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            
            eventPicView.image = selectedImage
            
            imageContent = selectedImage
            imageAdded = true
            
            imageID = "\(NSUUID().uuidString).jpg"
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func picUpload(uid: String, handler: @escaping (_ url: URL) -> ()) {
        
        //Delete the old event photo if editing
        if editingGigEvent && gigEvent != nil {
            DataService.instance.deleteSTFile(uid: user!.uid, directory: "events", fileID: gigEvent!.getid())
        }
        
        if let eventPic = eventPicView.image {
            
            DataService.instance.updateSTPic(uid: uid, directory: "events", imageContent: eventPic, imageID: imageID, uploadComplete: { (success, error) in
                if error != nil {
                    
                    self.displayError(title: "There was an Error", message: error!.localizedDescription)
                    
                } else {
                    
                    DataService.instance.getSTURL(uid: uid, directory: "events", imageID: self.imageID) { (returnedURL) in
                        
                        handler(returnedURL)
                    }
                }
            })
        }
    }
    
    @IBAction func postEvent(_ sender: Any) {
        
        if imageAdded {
            
            let range = imageID.index(imageID.endIndex, offsetBy: -4)..<imageID.endIndex
            imageID.removeSubrange(range)//'remove the .jpg from the imageID
            //eventID needed for deletion
            eventID = imageID
            
            eventData!["eventID"] = eventID
            
            print(eventData!)
            
            self.picUpload(uid: user!.uid) {
                (returnedURL) in
                
                self.eventData!["eventPhotoURL"] = returnedURL.absoluteString
                
                self.eventData!["appliedUsers"] = ["CREATOR:\(self.user!.uid)": true]
                
                //Add the event to the database
                DataService.instance.updateDBEvents(uid: self.user!.uid, eventID: self.eventID, eventData: self.eventData!)
                
                //Add the event under user to the database
                DataService.instance.updateDBUserEvents(uid: self.user!.uid, eventID: self.eventID)
                
                self.updateActivity()
                
                //Update the activity feed in a completion handler so it updates correctly
                DataService.instance.updateDBActivityFeed(uid: self.notificationData!["reciever"] as! String, notificationID: self.notificationData!["notificationID"] as! String, notificationData: self.notificationData!) { (complete) in
                    
                    if complete {
                        //Take user to Activity tab to see their posted event
                        //Without completion handler we were jumping to the view controller before the activity had updated
                        self.tabBarController?.selectedIndex = 2
                        
                        //clear the event creation and pop to root of the navigation stack
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
            
        } else {
            
            displayError(title: "Oops", message: "Please take or add a photo of the venue to post event")
        }
    }
    
    func updateActivity() {
        let notificationID = NSUUID().uuidString
        let senderUid = user!.uid
        let recieverUid = senderUid
        let senderName = "You"
        let notificationPicURL = user!.picURL.absoluteString
        let notificationDescription = "Created the event: \((eventData!["title"])!)"
        let timestamp = NSDate().timeIntervalSince1970
        notificationData = ["notificationID": notificationID, "relatedEventID": eventID, "type": "personal", "sender": senderUid, "reciever": recieverUid, "senderName": senderName, "picURL": notificationPicURL, "description": notificationDescription, "timestamp": timestamp]
    }
}

