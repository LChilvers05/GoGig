//
//  FindGigVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 12/05/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//
//  TODO: WHAT IF USER DOES NOT OPT FOR LOCATION SERVICES?

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FindGigVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var contactStack: UIStackView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var currentGigEventView: GigEventView!
    @IBOutlet weak var nextGigEventView: GigEventView!
    @IBOutlet weak var refreshButton: UIButton!
    
    
    var user: User?
    var gigEvents = [GigEvent]()
    var notificationData: Dictionary<String, Any>?
    //create a location manager for sorting events
    let locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        cardGateOpen = false
        
        //function is called when gesture is recognised
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(self.gigEventWasDragged(gestureRecogniser:)))
        
        //assign the drag gesture to the view
        currentGigEventView.isUserInteractionEnabled = true
        currentGigEventView.addGestureRecognizer(dragGesture)
        //front card is in the centre of the view
        currentGigEventView.center = CGPoint(x: self.view.frame.width / 2, y: (self.view.frame.height / 2) + 60)
        self.view.sendSubviewToBack(currentGigEventView)
        //back card will be slightly above the front card (looks like stack)
        nextGigEventView.center = CGPoint(x: self.view.bounds.width / 2, y: (self.view.bounds.height / 2) + 30)
        nextGigEventView.alpha = 0.6
        self.view.sendSubviewToBack(nextGigEventView)
        //refresh button for when there are no more cards
        refreshButton.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
        self.view.sendSubviewToBack(refreshButton)
        //hide everything before refreshing
        nameLabel.isHidden = true
        emailLabel.isHidden = true
        phoneLabel.isHidden = true
        nextGigEventView.isHidden = true
        currentGigEventView.isHidden = true
        
        refresh()
        
        setupView()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        //so it doesn't refresh everytime view appears (only once)
        if cardGateOpen {
            cardGateOpen = false
            refresh()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        //stop using location to save battery
        locationManager.stopUpdatingLocation()
    }
    @IBAction func refreshButton(_ sender: Any) {
        refresh()
    }
    func refresh() {
        //get the current user profile
        if let uid = Auth.auth().currentUser?.uid {
            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                self.user = returnedUser
                //and start updating location if they have authorised it
                self.locationManager.delegate = self
                self.locationManager.startUpdatingLocation()
                //get all the GigEvents in an array...
                DataService.instance.getDBEvents(uid: uid) { (returnedGigEvents) in
                    //...and sort them by locality
                    self.gigEvents = self.setGigEventDistances(gigs: returnedGigEvents)
                    //show the cards to musician
                    self.updateCards()
                    
                }
            }
        }
    }
    
    //MARK: SORT GIGS BY LOCATION
    var userLatitude =  0.00
    var userLongitude = 0.00
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //grab the coordinates of the current user
        let userLocation: CLLocation = locations[0]
        userLatitude = userLocation.coordinate.latitude
        userLongitude = userLocation.coordinate.longitude
    }
    
    //compare the two coordinates of the gig and the user
    //update the distance attrribute
    //then use the distance to do a quick sort
    func setGigEventDistances(gigs: [GigEvent]) -> [GigEvent] {
        
        //instanitate a location out of coordinates
        let userLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
        //for each gig there is...
        for gig in gigs {
            //...get the location of the GigEvent object
            let gigEventLocation = gig.getGigEventLocation()
            //find the distance between the two
            let distance = gigEventLocation.distance(from: userLocation) as Double
            //set the distance from user of the GigEvent object
            gig.setDistance(distanceFromUser: distance)
        }
        //sort the objects by distance and return the new array
        return quickSort(array: gigs)
    }
    
    //MARK: GIG EVENT CARDS
    
    //keep track of what object has been swiped
    var interactedGigEvent: GigEvent?
    //keep track of what object is next
    var nextEventImage: UIImage?
    
    func displayGigEventInfo(gigEventView: GigEventView, gigEvent: GigEvent) {
        //show data about the event on the card
        gigEventView.dayDateLabel.text = gigEvent.getDayDate()
        gigEventView.monthYearDateLabel.text = gigEvent.getLongMonthYearDate()
        gigEventView.timeLabel.text = gigEvent.getTime()
        gigEventView.titleLabel.text = gigEvent.getTitle()
        gigEventView.paymentLabel.text = "For: £\(gigEvent.getPayment())"
    }
    
    func updateCards() {
        //show the contact information
        nameLabel.isHidden = false
        emailLabel.isHidden = false
        phoneLabel.isHidden = false
        refreshButton.isHidden = true
        nextGigEventView.isHidden = true
        
        //if there are gigs to apply for
        if gigEvents.count >= 1 {
            
            //the gig upfront
            if let currentGigEvent = gigEvents.first {
                //will be interacted with
                interactedGigEvent = currentGigEvent
                
                nameLabel.text = currentGigEvent.getName()
                emailLabel.text = currentGigEvent.getEmail()
                phoneLabel.text = currentGigEvent.getPhone()
                
                //set the UI for the first in array
                displayGigEventInfo(gigEventView: currentGigEventView, gigEvent: currentGigEvent)

                //get image from nextGigEventView or download one
                if nextEventImage != nil {
                    //reuse the image from card behind
                    currentGigEventView.eventPhotoImageView.image = nextEventImage
                } else {
                    //download one if its first time loading array
                    downloadImage(url: currentGigEvent.getEventPhotoURL()) { (returnedImage) in
                        self.currentGigEventView.eventPhotoImageView.image = returnedImage
                    }
                }
            }
            //show the card upfront
            currentGigEventView.isHidden = false
            
            //if more than one gigEvent
            if gigEvents.count > 1 {
                
                //display the nextGigEventView behind with the next gigEvent in line
                nextGigEventView.isHidden = false
                let nextGigEvent = gigEvents[1]
                
                displayGigEventInfo(gigEventView: nextGigEventView, gigEvent: nextGigEvent)

                //this image is always downloaded
                downloadImage(url: nextGigEvent.getEventPhotoURL()) { (returnedImage) in

                    self.nextGigEventView.eventPhotoImageView.image = returnedImage
                    self.nextEventImage = returnedImage
                }
                
            }
            
        } else {
            //no gigs to apply for, tell user
            nameLabel.text = "No Gigs Around"
            emailLabel.text = "Share GoGig"
            nextEventImage = nil
            phoneLabel.isHidden = true
            currentGigEventView.isHidden = true
            nextGigEventView.isHidden = true
            refreshButton.isHidden = false
        }
    }
    
    
    @IBAction func checkEvent(_ sender: Any) {
        performSegue(withIdentifier: TO_EVENT_DESCRIPTION, sender: nil)
    }
    
    
    //MARK: UPDATE APPLIED USERS
    
    func didChoose(applied: Bool){
        
        //get the interacted users of that event
        var gigEventAppliedUsers = interactedGigEvent?.getAppliedUsers()
        //and add a new key with the current users uid
        gigEventAppliedUsers![user!.uid] = applied
        
        //update the dictionary in the database
        DataService.instance.updateDBEventsInteractedUsers(uid: user!.uid, eventID: interactedGigEvent!.getid(), eventData: gigEventAppliedUsers!)
        
        if applied {
            //tell musician that they have applied with a notification
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
        //reciever is user that created gig
        let recieverUid = interactedGigEvent!.getuid()
        let senderName = user!.name
        let notificationPicURL = user!.picURL.absoluteString
        let notificationDescription = "applied for the event: \(interactedGigEvent!.getTitle())"
        let timestamp = NSDate().timeIntervalSince1970
        notificationData = ["notificationID": notificationID, "relatedEventID": relatedEventID, "type": "applied", "sender": senderUid, "reciever": recieverUid, "senderName": senderName, "picURL": notificationPicURL, "description": notificationDescription, "timestamp": timestamp]
        
        //send a push notification to event creator
        DataService.instance.getDBUserProfile(uid: recieverUid) { (returnedUser) in
            DataService.instance.sendPushNotification(to: returnedUser.getFCMToken(), title: "Application pending", body: "\(senderName) has applied for your event")
        }
        //notify creator
        DataService.instance.updateDBActivityFeed(uid: recieverUid, notificationID: notificationID, notificationData: notificationData!) { (complete) in
            if complete {
                //notify current user about their action (sender is themself to reciever themself)
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

        //returns a vector of where user drags to
        let translation = gestureRecogniser.translation(in: view)
        
        let theView = gestureRecogniser.view!
        
        //move the view to where the user is dragging
        theView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        //calculate distance of view from the centre
        let xFromCenter = theView.center.x - self.view.bounds.width / 2
        
        //view will rotate as it moved further from centre (radians)
        //will rotate less the further from the centre it goes - view won't go upside down
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        
        //shrink the card as it reaches screen edge - set the scale
        let scale = min(abs(100 / xFromCenter), 1)
        
        //the stretch and rotation effect set by the scale
        var stretchAndRotation = rotation.scaledBy(x: scale, y: scale)
        
        //apply the rotation and stretch to the view
        theView.transform = stretchAndRotation
        
        //when the user finished dragging
        if gestureRecogniser.state == UIGestureRecognizer.State.ended {
            
            //the area at which a definite choice has been made:
            //dragged left
            if theView.center.x < 40 {
                //call function to do actions based on their choice
                didChoose(applied: false)
                //call function to show confirmation (musician knows what they have done)
                confirmChoiceAnimation(applied: false)
                
                //return the view to the centre
                rotation = CGAffineTransform(rotationAngle: 0)
                stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
                theView.transform = stretchAndRotation
                theView.center = CGPoint(x: self.view.bounds.width / 2, y: (self.view.bounds.height / 2) + 60)
                
            //dragged right
            } else if theView.center.x > self.view.bounds.width - 40 {
                
                didChoose(applied: true)
                confirmChoiceAnimation(applied: true)
                
                rotation = CGAffineTransform(rotationAngle: 0)
                stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
                theView.transform = stretchAndRotation
                theView.center = CGPoint(x: self.view.bounds.width / 2, y: (self.view.bounds.height / 2) + 60)
            }
        }
    }
    
    func confirmChoiceAnimation(applied: Bool) {
        var confirmationImageView: UIImageView?
        if applied {
            //will be a tick image
            confirmationImageView = UIImageView(image: UIImage(named: "appliedGigEvent"))
        } else {
            //will be a cross image
            confirmationImageView = UIImageView(image: UIImage(named: "ignoredGigEvent"))
        }
        //
        confirmationImageView!.frame = CGRect.init(x: 0, y: 0, width: 100, height: 100)
        confirmationImageView!.center = self.view.center
        //subtle confirmation
        confirmationImageView!.alpha = 0.5
        view.addSubview(confirmationImageView!)
        //grow and fade
        UIView.animate(withDuration: 0.2, animations: {
            //grow x1.3
            confirmationImageView!.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        }) { (complete) in
            //fade in 0.2 seconds from 0.5 opacity to 0.0
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
                confirmationImageView!.alpha = 0.0
            }) { (complete) in
                //after animation, remove it from the view
                confirmationImageView!.removeFromSuperview()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_EVENT_DESCRIPTION {
            
            let eventDescriptionVC = segue.destination as! EventDescriptionVC
            //make sure there is a purple back button
            let backItem = UIBarButtonItem()
            backItem.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            eventDescriptionVC.gigEvent = interactedGigEvent
        }
    }
}

