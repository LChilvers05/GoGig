//
//  ReviewApplicationVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 31/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ReviewApplicationVC: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var nameButton: UIButton!
    
    var user: User?
    var currentUser: User?
    var uid: String?
    var application: ActivityNotification?
    var relatedEvent: GigEvent?
    var notificationData: Dictionary<String, Any>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        //refresh called in previous view
    }
    
    func refresh() {
        if let currentUserUid = Auth.auth().currentUser?.uid {
            DataService.instance.getDBUserProfile(uid: currentUserUid) { (returnedCurrentUser) in
                self.currentUser = returnedCurrentUser
                DataService.instance.getDBUserProfile(uid: self.uid!) { (returnedUser) in
                    self.user = returnedUser
                    self.nameLabel.text = returnedUser.name
                    self.nameButton.setTitle("Check out \(returnedUser.name)", for: .normal)
                    self.loadImageCache(url: returnedUser.picURL, isImage: true) { (returnedProfileImage) in
                        self.profileImageView.image = returnedProfileImage
                        
                        DataService.instance.getDBSingleEvent(uid: returnedCurrentUser.uid, eventID: self.application!.getRelatedEventId()) { (returnedGigEvent) in
                            
                            self.relatedEvent = returnedGigEvent
                            self.eventLabel.text = "Wants to play for \(returnedGigEvent.getTitle())"
                        }
                    }
                }
            }
        }
    }
    

    @IBAction func checkUid(_ sender: Any) {
        performSegue(withIdentifier: TO_CHECK_PORTFOLIO_2, sender: nil)
    }
    
    @IBAction func rejectUser(_ sender: Any) {
        updateActivity(accepted: false)
        //Don't delete the notification on rejection because user may change their mind
    }
    @IBAction func acceptUser(_ sender: Any) {
        updateActivity(accepted: true)
        //Need to delete the notification so that you cannot accept the user again and again
        //MAY NEED TO OBSERVE THE DELETION SO THAT IT REMOVES THE ROW
        
        DataService.instance.deleteDBActivityFeed(uid: currentUser!.uid, notificationID: application!.getId())
        
        //The user has been accepted, so add that to their 'My Events List'
        DataService.instance.updateDBUserEvents(uid: user!.uid, eventID: application!.getRelatedEventId())
    }
    
    func updateActivity(accepted: Bool) {
        //This line stops the button being pressed twice sending two activity updates
        self.view.isUserInteractionEnabled = false
        
        let notificationID = NSUUID().uuidString
        guard let senderUid = currentUser?.uid else { return }
        guard let recieverUid = uid else { return }
        guard let senderName = currentUser?.name else { return }
        guard let notificationPicURL = currentUser?.picURL.absoluteString else { return }
        guard let relatedEventTitle = relatedEvent?.getTitle() else { return }
        guard let relatedEventID = relatedEvent?.getid() else { return }
        
        //We need to grab the event as well
        var notificationDescription: String?
        if accepted {
            notificationDescription = "Hired you for the event: \(relatedEventTitle)"
            
            //Send a push notification to other user
            DataService.instance.getDBUserProfile(uid: recieverUid) { (returnedUser) in
                DataService.instance.sendPushNotification(to: returnedUser.getFCMToken(), title: "You got the gig!", body: "\(senderName) hired you for the event: \(relatedEventTitle)")
            }
        } else {
            notificationDescription = "Declined you for the event: \(relatedEventTitle)"
        }
        let timestamp = NSDate().timeIntervalSince1970
        notificationData = ["notificationID": notificationID, "relatedEventID": relatedEventID, "type": "reply", "sender": senderUid, "reciever": recieverUid, "senderName": senderName, "picURL": notificationPicURL, "description": notificationDescription!, "timestamp": timestamp]

        //Notify Other User
        DataService.instance.updateDBActivityFeed(uid: recieverUid, notificationID: notificationID, notificationData: notificationData!) { (complete) in
            if complete && accepted {
                //Notify Current User about their action (sender is themself to reciever themself)
                self.notificationData!["senderName"] = "You"
                self.notificationData!["reciever"] = senderUid
                self.notificationData!["type"] = "personal"
                self.notificationData!["description"] = "Hired \(self.user!.name) for the event: \(relatedEventTitle)"
                DataService.instance.updateDBActivityFeed(uid: senderUid, notificationID: notificationID, notificationData: self.notificationData!) { (complete) in
                    if complete {
                    }
                }
            }
        }
        self.view.isUserInteractionEnabled = true
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_CHECK_PORTFOLIO_2 {
            
            let userAccountVC = segue.destination as! UserAccountVC
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            userAccountVC.uid = uid
            userAccountVC.observingPortfolio = true
            userAccountVC.refreshPortfolio()
        }
    }
}
