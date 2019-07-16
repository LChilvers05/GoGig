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
    
    var user: User?
    var gigEvents = [GigEvent]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let uid = Auth.auth().currentUser?.uid {
            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                self.user = returnedUser
                DataService.instance.getDBEvents(uid: uid) { (returnedGigEvents) in
                    self.gigEvents = returnedGigEvents
                    
                    self.showEvidence()
                }
            }
        }
    }
    
    func showEvidence() {
        for gigEvent in gigEvents {
            print(gigEvent.getTitle() + ":")
            print("\(gigEvent.getuid()) (\(gigEvent.getName())) has published this event for \(gigEvent.getTime())")
            print("With the description:")
            print(gigEvent.getDescription())
        }
    }
        
    //    var user: User?
    //
    //    override func viewDidLoad() {
    //        super.viewDidLoad()
    //
    //        navigationController?.setNavigationBarHidden(true, animated: false)
    //    }
    //
    //    override func viewDidAppear(_ animated: Bool) {
    //        if let uid = Auth.auth().currentUser?.uid {
    //            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
    //                self.user = returnedUser
    //                if returnedUser.gigs == false {
    //                    self.performSegue(withIdentifier: TO_CREATE_GIG, sender: nil)
    //                }
    //            }
    //        }
    //    }
}

