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
            //get the current user
            DataService.instance.getDBUserProfile(uid: currentUserUid) { (returnedCurrentUser) in
                self.currentUser = returnedCurrentUser
                //get the musician that applied
                DataService.instance.getDBUserProfile(uid: self.uid!) { (returnedUser) in
                    self.user = returnedUser
                    //change outlets
                    self.nameLabel.text = returnedUser.name
                    self.nameButton.setTitle("Check out \(returnedUser.name)", for: .normal)
                    //load the image
                    self.loadImageCache(url: returnedUser.picURL, isImage: true) { (returnedProfileImage) in
                        self.profileImageView.image = returnedProfileImage
                        //get the gig object
                        DataService.instance.getDBSingleEvent(uid: returnedCurrentUser.uid, eventID: self.application!.getRelatedEventId()) { (returnedGigEvent, sucess) in
                            
                            self.relatedEvent = returnedGigEvent
                            //update the UI
                            self.eventLabel.text = "Wants to play for \(returnedGigEvent.getTitle())"
                        }
                    }
                }
            }
        }
    }
    
    //back
    @IBAction func popView(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    //look at musician's portfolio
    @IBAction func checkUid(_ sender: Any) {
        performSegue(withIdentifier: TO_CHECK_PORTFOLIO_2, sender: nil)
    }
    
    @IBAction func rejectUser(_ sender: Any) {
        updateActivity(accepted: false)
        //don't delete the notification on rejection because user may change their mind
    }
    @IBAction func acceptUser(_ sender: Any) {
        updateActivity(accepted: true)
        //need to delete the notification so that you cannot accept the user again and again
        DataService.instance.deleteDBActivityFeed(uid: currentUser!.uid, notificationID: application!.getId())
        
        //The user has been accepted, so add that to their 'My Events List'
        DataService.instance.updateDBUserEvents(uid: user!.uid, eventID: application!.getRelatedEventId())
    }
    
    func updateActivity(accepted: Bool) {
        //this line stops the button being pressed twice sending two activity updates
        self.view.isUserInteractionEnabled = false
        
        //set all the data for the notification
        let notificationID = NSUUID().uuidString
        guard let senderUid = currentUser?.uid else { return }
        guard let recieverUid = uid else { return }
        guard let senderName = currentUser?.name else { return }
        guard let notificationPicURL = currentUser?.picURL.absoluteString else { return }
        guard let relatedEventTitle = relatedEvent?.getTitle() else { return }
        guard let relatedEventID = relatedEvent?.getid() else { return }
        
        //grab the event as well
        var notificationDescription: String?
        if accepted {
            notificationDescription = "hired you for the event: \(relatedEventTitle)"
            
            //send a push notification musician
            DataService.instance.getDBUserProfile(uid: recieverUid) { (returnedUser) in
                DataService.instance.sendPushNotification(to: returnedUser.getFCMToken(), title: "You got the gig!", body: "\(senderName) hired you for the event: \(relatedEventTitle)")
            }
        } else {
            notificationDescription = "declined you for the event: \(relatedEventTitle)"
        }
        let timestamp = NSDate().timeIntervalSince1970
        notificationData = ["notificationID": notificationID, "relatedEventID": relatedEventID, "type": "reply", "sender": senderUid, "reciever": recieverUid, "senderName": senderName, "picURL": notificationPicURL, "description": notificationDescription!, "timestamp": timestamp]

        //notify musician
        DataService.instance.updateDBActivityFeed(uid: recieverUid, notificationID: notificationID, notificationData: notificationData!) { (complete) in
            if complete && accepted {
                //notify Current User about their action (sender is themself to recieve themself)
                self.notificationData!["senderName"] = "You"
                self.notificationData!["reciever"] = senderUid
                self.notificationData!["type"] = "personal"
                self.notificationData!["description"] = "hired \(self.user!.name) for the event: \(relatedEventTitle)"
                DataService.instance.updateDBActivityFeed(uid: senderUid, notificationID: notificationID, notificationData: self.notificationData!) { (complete) in
                    if complete {
                    }
                }
            }
        }
        //allow interaction again
        self.view.isUserInteractionEnabled = true
        //go back to activty feed
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //setup destination ready to observe musician's portfolio
        if segue.identifier == TO_CHECK_PORTFOLIO_2 {
            
            let userAccountVC = segue.destination as! UserAccountVC
            
            let backItem = UIBarButtonItem()
            backItem.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            userAccountVC.uid = uid
            userAccountVC.observingPortfolio = true
            userAccountVC.refreshPortfolio()
        }
    }
}
