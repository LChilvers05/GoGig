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
    
    //!! When the user posts, two of each comes up, because of this code
    
    var user: User?
    
    //Save on the device the set of tabs that should appear if the user is logged in
    //if not logged in, then query the database to find out the user type
    
    override func viewDidAppear(_ animated: Bool) {
        
        //Set the original state of the tabs (all four)
        if tabGateOpen {
            tabs = self.viewControllers!
        }
        
        if let userGigs = DEFAULTS.object(forKey: "gigs") as? Bool {
            
            //print(userGigs)
            
            //Remove the tabs that shouldn't be seen by musician/organiser
            if tabGateOpen {
                if userGigs == true {
                    self.viewControllers?.remove(at: 0)
                } else {
                    self.viewControllers?.remove(at: 1)
                }
                
                tabGateOpen = false
                
                //Initial tab is the profile tab
                self.selectedIndex = 1
            }
        } else {
            
            //Remove the tabs that shouldn't be seen by musician/organiser
            if let uid = Auth.auth().currentUser?.uid {
                DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                    self.user = returnedUser
                    if tabGateOpen {
                        if returnedUser.gigs == true {
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
                    }
                    
                    //Makes the initial tab the profile tab
                    self.selectedIndex = 1;
                    
                }
            }
        }
    }
}

//Tab Bar Original State
var tabs = [UIViewController]()
var tabGateOpen = true

