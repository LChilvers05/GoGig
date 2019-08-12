//
//  FindGigVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 12/05/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FindGigVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var currentGigEventView: GigEventView!
    @IBOutlet weak var nextGigEventView: GigEventView!
    
    
    var user: User?
    var gigEvents = [GigEvent]()
    var notificationData: Dictionary<String, Any>?
    
    let locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        //To nearest hundred metres, to save battery
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        cardGateOpen = false
        
        //Function is called when gesture is recognised
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(self.gigEventWasDragged(gestureRecogniser:)))
        
        //Assign the drag gesture to the view
        currentGigEventView.isUserInteractionEnabled = true
        currentGigEventView.addGestureRecognizer(dragGesture)
        
        nextGigEventView.center = CGPoint(x: self.view.bounds.width / 2, y: (self.view.bounds.height / 2) + 30)
        nextGigEventView.alpha = 0.6
        self.view.sendSubviewToBack(nextGigEventView)
        
        nameLabel.isHidden = true
        emailLabel.isHidden = true
        phoneLabel.isHidden = true
        nextGigEventView.isHidden = true
        currentGigEventView.isHidden = true
        
        refresh()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        if cardGateOpen {
            cardGateOpen = false
            refresh()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    func refresh() {
        if let uid = Auth.auth().currentUser?.uid {
            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                self.user = returnedUser
                DataService.instance.getDBEvents(uid: uid) { (returnedGigEvents) in
                    //self.gigEvents = returnedGigEvents
                    self.gigEvents = self.setGigEventDistances(gigs: returnedGigEvents)
                    
                    self.updateCards()
                }
            }
        }
    }
    
    //MARK: SORT GIGS BY LOCATION
    var userLatitude =  0.00
    var userLongitude = 0.00
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        userLatitude = userLocation.coordinate.latitude
        userLongitude = userLocation.coordinate.longitude
    }
    
    //We compare the two coordinates of the gig and the user
    //update the distance attrribute
    //then use the distance to do a quick sort
    func setGigEventDistances(gigs: [GigEvent]) -> [GigEvent] {
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
        
        for gig in gigs {
            
            let gigEventLocation = gig.getGigEventLocation()
            let distance = gigEventLocation.distance(from: userLocation) as Double
            
            gig.setDistance(distanceFromUser: distance)
        }
        
        return quickSort(array: gigs)
    }
    
    //MARK: GIG EVENT CARDS
    
    var interactedGigEvent: GigEvent?
    var nextEventImage: UIImage?
    
    func displayGigEventInfo(gigEventView: GigEventView, gigEvent: GigEvent) {
        
        gigEventView.dayDateLabel.text = gigEvent.getDayDate()
        gigEventView.monthYearDateLabel.text = gigEvent.getLongMonthYearDate()
        gigEventView.timeLabel.text = gigEvent.getTime()
        gigEventView.titleLabel.text = gigEvent.getTitle()
        gigEventView.paymentLabel.text = "For: £\(gigEvent.getPayment())"
    }
    
    func updateCards() {
        
        nameLabel.isHidden = false
        emailLabel.isHidden = false
        phoneLabel.isHidden = false
        
        nextGigEventView.isHidden = true
        
        //if there are gigs to apply for
        if gigEvents.count >= 1 {
            
            //The gig upfront
            if let currentGigEvent = gigEvents.first {
                
                interactedGigEvent = currentGigEvent
                
                nameLabel.text = currentGigEvent.getName()
                emailLabel.text = currentGigEvent.getEmail()
                phoneLabel.text = currentGigEvent.getPhone()
                
//                currentGigEventView.dayDateLabel.text = currentGigEvent.getDayDate()
//                currentGigEventView.monthYearDateLabel.text = currentGigEvent.getLongMonthYearDate()
//                currentGigEventView.timeLabel.text = currentGigEvent.getTime()
//                currentGigEventView.titleLabel.text = currentGigEvent.getTitle()
//                currentGigEventView.paymentLabel.text = "For: £\(currentGigEvent.getPayment())"
                
                //set the UI for the first in array
                displayGigEventInfo(gigEventView: currentGigEventView, gigEvent: currentGigEvent)
                
                //get image from nextGigEventView or download one
                if nextEventImage != nil {
                    currentGigEventView.eventPhotoImageView.image = nextEventImage
                } else {
                    downloadImage(url: currentGigEvent.getEventPhotoURL()) { (returnedImage) in
                        
                        self.currentGigEventView.eventPhotoImageView.image = returnedImage
                    }
                }
            }
                
            currentGigEventView.isHidden = false
            
            //if more than one gigEvent
            if gigEvents.count > 1 {
                
                //display the nextGigEventView behind with the next gigEvent in line
                nextGigEventView.isHidden = false
                let nextGigEvent = gigEvents[1]
                
//                nextGigEventView.dayDateLabel.text = nextGigEvent.getDayDate()
//                nextGigEventView.monthYearDateLabel.text = nextGigEvent.getLongMonthYearDate()
//                nextGigEventView.timeLabel.text = nextGigEvent.getTime()
//                nextGigEventView.titleLabel.text = nextGigEvent.getTitle()
//                nextGigEventView.paymentLabel.text = "For: £\(nextGigEvent.getPayment())"
                
                displayGigEventInfo(gigEventView: nextGigEventView, gigEvent: nextGigEvent)
                
                //this image is always downloaded
                downloadImage(url: nextGigEvent.getEventPhotoURL()) { (returnedImage) in
                    
                    self.nextGigEventView.eventPhotoImageView.image = returnedImage
                    self.nextEventImage = returnedImage
                }
                
            }
            
        } else {
            //No gigs to apply for
            nameLabel.text = "No Gigs Around"
            emailLabel.text = "Share GoGig"
            nextEventImage = nil
            currentGigEventView.isHidden = true
            nextGigEventView.isHidden = true
        }
    }
    
    
    @IBAction func checkEvent(_ sender: Any) {
        performSegue(withIdentifier: TO_EVENT_DESCRIPTION, sender: nil)
    }
    
    
    //MARK: UPDATE APPLIED USERS
    
    func didChoose(applied: Bool){
        
        //Get the interacted users of that event
        var gigEventAppliedUsers = interactedGigEvent?.getAppliedUsers()
        //and add a new key with the current users uid
        gigEventAppliedUsers![user!.uid] = applied
        
        //update the dictionary in the database
        DataService.instance.updateDBEventsInteractedUsers(uid: user!.uid, eventID: interactedGigEvent!.getid(), eventData: gigEventAppliedUsers!)
        
        if applied {
            updateActivity()
        }
        
        //remove the card from the gigEvent stack
        gigEvents.remove(at:0)
        
        //update the UI
        updateCards()
    }
    
    func updateActivity() {
        let notificationID = NSUUID().uuidString
        let relatedEventID = interactedGigEvent!.getid()
        let senderUid = user!.uid
        let recieverUid = interactedGigEvent!.getuid()
        let senderName = user!.name
        let notificationPicURL = user!.picURL.absoluteString
        let notificationDescription = "applied for the event: \(interactedGigEvent!.getTitle())"
        let timestamp = NSDate().timeIntervalSince1970
        notificationData = ["notificationID": notificationID, "relatedEventID": relatedEventID, "type": "applied", "sender": senderUid, "reciever": recieverUid, "senderName": senderName, "picURL": notificationPicURL, "description": notificationDescription, "timestamp": timestamp]
        
        //Notify Other User
        DataService.instance.updateDBActivityFeed(uid: recieverUid, notificationID: notificationID, notificationData: notificationData!) { (complete) in
            if complete {
                //Notify Current User about their action (sender is themself to reciever themself)
                self.notificationData!["senderName"] = "You"
                self.notificationData!["reciever"] = senderUid
                self.notificationData!["type"] = "personal"
                DataService.instance.updateDBActivityFeed(uid: senderUid, notificationID: notificationID, notificationData: self.notificationData!) { (complete) in
                }
            }
        }
    }
    
    //MARK: GESTURE METHOD
    
    //called method when the gesture is recognised
    //Pan Gesture - swipe across screen
    @objc func gigEventWasDragged(gestureRecogniser: UIPanGestureRecognizer) {

        //Returns a vector of where user drags to
        let translation = gestureRecogniser.translation(in: view)
        
        let theView = gestureRecogniser.view!
        
        //move the view to where the user is dragging
        theView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        //calculate distance of view from the centre
        let xFromCenter = theView.center.x - self.view.bounds.width / 2
        
        //view will rotate more as it moved further from centre (radians)
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        
        //will rotate less the further from centre is goes - view won't go upside down
        let scale = min(abs(100 / xFromCenter), 1)
        
        //the rotation effect set by the scale
        var stretchAndRotation = rotation.scaledBy(x: scale, y: scale)
        
        //apply the rotation and stretch to the view
        theView.transform = stretchAndRotation
        
        //when the user finished dragging
        if gestureRecogniser.state == UIGestureRecognizer.State.ended {
            
            //the area at which a definite choice has been made:
            //dragged left
            if theView.center.x < 40 {
                
                didChoose(applied: false)
                
                //return the view to the centre
                rotation = CGAffineTransform(rotationAngle: 0)
                stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
                theView.transform = stretchAndRotation
                theView.center = CGPoint(x: self.view.bounds.width / 2, y: (self.view.bounds.height / 2) + 40)
                
            //dragged right
            } else if theView.center.x > self.view.bounds.width - 40 {
                
                didChoose(applied: true)
                
                rotation = CGAffineTransform(rotationAngle: 0)
                stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
                theView.transform = stretchAndRotation
                theView.center = CGPoint(x: self.view.bounds.width / 2, y: (self.view.bounds.height / 2) + 40)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_EVENT_DESCRIPTION {
            
            let eventDescriptionVC = segue.destination as! EventDescriptionVC
            
            eventDescriptionVC.gigEvent = interactedGigEvent
        }
    }
}

