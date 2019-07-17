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
    @IBOutlet weak var gigEventView: GigEventView!
    
    var user: User?
    var gigEvents = [GigEvent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Function is called when gesture is recognised
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(self.gigEventWasDragged(gestureRecogniser:)))
        
        //Assign the drag gesture to the view
        gigEventView.isUserInteractionEnabled = true
        gigEventView.addGestureRecognizer(dragGesture)
        
        
        if let uid = Auth.auth().currentUser?.uid {
            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                self.user = returnedUser
                DataService.instance.getDBEvents(uid: uid) { (returnedGigEvents) in
                    self.gigEvents = returnedGigEvents
                    
                    self.updateView()
                }
            }
        }
    }
    
    func updateView() {
        
        let currentGigEvent = gigEvents.first
        
        nameLabel.text = currentGigEvent?.getName()
        emailLabel.text = currentGigEvent?.getEmail()
        phoneLabel.text = currentGigEvent?.getPhone()
        
        gigEventView.viewLabel.text = currentGigEvent?.getTitle()
    }
    
    
    @objc func gigEventWasDragged(gestureRecogniser: UIPanGestureRecognizer) {
        
        let translation = gestureRecogniser.translation(in: view)
        
        let theView = gestureRecogniser.view!
        
        theView.center = CGPoint(x: self.view.bounds.width / 2 + translation.x, y: self.view.bounds.height / 2 + translation.y)
        
        let xFromCenter = theView.center.x - self.view.bounds.width / 2
        
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        
        let scale = min(abs(100 / xFromCenter), 1)
        
        var stretchAndRotation = rotation.scaledBy(x: scale, y: scale)
        
        theView.transform = stretchAndRotation
        
        if gestureRecogniser.state == UIGestureRecognizer.State.ended {
            
            if theView.center.x < 40 {
                
                print("dragged left")
                
                rotation = CGAffineTransform(rotationAngle: 0)
                
                stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
                
                theView.transform = stretchAndRotation
                
                theView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
                
            } else if theView.center.x > self.view.bounds.width - 40 {
                
                print("dragged right")
                
                rotation = CGAffineTransform(rotationAngle: 0)
                
                stretchAndRotation = rotation.scaledBy(x: 1, y: 1)
                
                theView.transform = stretchAndRotation
                
                theView.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            }
            
            
            
            
        }
        
    }
}

