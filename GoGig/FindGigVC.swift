//
//  FindGigVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 12/05/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class FindGigVC: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var currentGigEventView: GigEventView!
    @IBOutlet weak var nextGigEventView: GigEventView!
    
    
    
    var user: User?
    var gigEvents = [GigEvent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Function is called when gesture is recognised
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(self.gigEventWasDragged(gestureRecogniser:)))
        
        //Assign the drag gesture to the view
        currentGigEventView.isUserInteractionEnabled = true
        currentGigEventView.addGestureRecognizer(dragGesture)
        
        nextGigEventView.center = CGPoint(x: self.view.bounds.width / 2, y: (self.view.bounds.height / 2) + 30)
        nextGigEventView.alpha = 0.5
        self.view.sendSubviewToBack(nextGigEventView)
        
        if let uid = Auth.auth().currentUser?.uid {
            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                self.user = returnedUser
                DataService.instance.getDBEvents(uid: uid) { (returnedGigEvents) in
                    self.gigEvents = returnedGigEvents
                    
                    self.updateCards()
                }
            }
        }
    }
    
    func updateCards() {
        
        nextGigEventView.isHidden = true
        
        if gigEvents.count >= 1 {
            
            //The gig upfront
            if let currentGigEvent = gigEvents.first {
                
                nameLabel.text = currentGigEvent.getName()
                emailLabel.text = currentGigEvent.getEmail()
                phoneLabel.text = currentGigEvent.getPhone()
                
                currentGigEventView.numericalDateLabel.text = currentGigEvent.getTime().substring(start: 8, end: 10)

                currentGigEventView.timeLabel.text = currentGigEvent.getTime().substring(start: 11, end: 16)
                currentGigEventView.titleLabel.text = currentGigEvent.getTitle()
                currentGigEventView.paymentLabel.text = "For: £\(currentGigEvent.getPayment())"
                //currentGigEventView.eventPhotoImageView.image = downloadImage(currentGigEvent.getEventPhotoURL)
            }
                
                currentGigEventView.isHidden = false
            
            if gigEvents.count > 1 {
                
                //The gig behind
                nextGigEventView.isHidden = false
                let nextGigEvent = gigEvents[1]
                
                nextGigEventView.numericalDateLabel.text = nextGigEvent.getTime().substring(start: 8, end: 10)

                nextGigEventView.timeLabel.text = nextGigEvent.getTime().substring(start: 11, end: 16)
                nextGigEventView.titleLabel.text = nextGigEvent.getTitle()
                nextGigEventView.paymentLabel.text = "For: £\(nextGigEvent.getPayment())"
                //currentGigEventView.eventPhotoImageView.image = downloadImage(currentGigEvent.getEventPhotoURL)
                
            }
            
        } else {
            //No gigs to apply for
            nameLabel.text = "No Gigs Around"
            emailLabel.text = "Share GoGig"
            currentGigEventView.isHidden = true
            nextGigEventView.isHidden = true
            
        }
    }
    
    //swipe right function
    func applyForGig() {
        
        print("the user applied for this gig")
        
    }
    
    //swipe left function
    func ignoreGig() {
        
        print("ignored this job")
        
        gigEvents.remove(at: 0)
        updateCards()
        
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
                
                ignoreGig()
                
                //return the view to the centre
                rotation = CGAffineTransform(rotationAngle: 0)
                stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
                theView.transform = stretchAndRotation
                theView.center = CGPoint(x: self.view.bounds.width / 2, y: (self.view.bounds.height / 2) + 40)
                
            //dragged right
            } else if theView.center.x > self.view.bounds.width - 40 {
                
                applyForGig()
                
                rotation = CGAffineTransform(rotationAngle: 0)
                stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
                theView.transform = stretchAndRotation
                theView.center = CGPoint(x: self.view.bounds.width / 2, y: (self.view.bounds.height / 2) + 40)
            }
        }
    }
}

