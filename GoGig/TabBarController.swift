//
//  TabBarController.swift
//  GoGig
//
//  Created by Lee Chilvers on 28/04/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class TabBarController: UITabBarController {
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }

    //view did appear here means that view did appear in the profile view does not work
    var userGigs: Bool?

    override func viewDidAppear(_ animated: Bool) {
        //Set the original state of the tabs (all four)
        if tabGateOpen {
            tabs = self.viewControllers!
        }
        
        //IF USER IS RESUMING
        if let userGigs = DEFAULTS.object(forKey: "gigs") as? Bool {

            //Remove the tabs that shouldn't be seen by musician/organiser
            if tabGateOpen {
                if userGigs == true {
                    self.viewControllers?.remove(at: 0)
                } else {
                    self.viewControllers?.remove(at: 1)
                }

                tabGateOpen = false
                
                //Makes the initial tab the profile tab
                self.selectedIndex = 1;
            }

        } else {

            if tabGateOpen {
            //Remove the tabs that shouldn't be seen by musician/organiser
                if let uid = Auth.auth().currentUser?.uid {
                    
                    //IF USER IS LOGGING IN
                    if userGigs == nil {
                        DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                            
                            self.setDefaults(userGigsCondition: returnedUser.gigs)
                        }
                        
                    //IF THE USER IS SIGNING UP FOR THE FIRST TIME
                    } else {
                        
                        self.setDefaults(userGigsCondition: userGigs!)
                    }
                }
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshPortfolio"), object: nil)
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshActivityFeed"), object: nil)
    }
    
    func setDefaults(userGigsCondition: Bool) {
        if userGigsCondition == true {
            //remove the create tab and view
            self.viewControllers?.remove(at: 0)
            
            //write value to device
            DEFAULTS.set(true, forKey: "gigs")
            
        } else {
            //remove the find tab and view
            self.viewControllers?.remove(at: 1)
            
            //write value to device
            DEFAULTS.set(false, forKey: "gigs")
        }
        
        tabGateOpen = false
        
        //Makes the initial tab the profile tab
        self.selectedIndex = 1;
    }
    //
}

//Tab Bar Original State
var tabs = [UIViewController]()
