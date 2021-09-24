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
    override func viewDidLoad() {
        super.viewDidLoad()
        //notification to refresh the tabs
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTabs), name: NSNotification.Name(rawValue: "refreshTabs"), object: nil)
    }
    //make sure that navigation bar (TabBarController is part of navigation stack)
    //is hidden, but tabBar is shown
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }

    var userGigs: Bool?
    //first launch only (use of gate so that tabs don't refresh
    //everytime view is shown)
    override func viewDidAppear(_ animated: Bool) {
        if tabGateOpen {
            refreshTabs()
        }
    }
    //logic to decide what tabs are shown
    @objc func refreshTabs(){
        print("Tabs have been refreshed")
        //set the original state of the tabs (all four)
        if tabGateOpen {
            tabs = self.viewControllers!
        }
        
        //IF USER IS RESUMING
        if let userGigsDefaults = DEFAULTS.object(forKey: "gigs") as? Bool {

            //remove the tabs that shouldn't be seen by musician/organiser
            if tabGateOpen {
                if userGigsDefaults == true {
                    self.viewControllers?.remove(at: 0)
                } else {
                    self.viewControllers?.remove(at: 1)
                }
                
                //safety so they don't refresh again
                tabGateOpen = false
                
                //makes the initial tab the portfolio tab
                self.selectedIndex = 1;
            }

        } else {

            if tabGateOpen {
            //remove the tabs that shouldn't be seen by musician/organiser
                if let uid = Auth.auth().currentUser?.uid {
                    
                    //IF USER IS LOGGING IN
                    if userGigs == nil {
                        DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                            //remember the tab state when logged in
                            self.setDefaults(userGigsCondition: returnedUser.gigs)
                        }
                        
                    //IF THE USER IS SIGNING UP FOR THE FIRST TIME OR EDITING THEIR PROFILE
                    } else {
                        //remember the tab state when logged in
                        self.setDefaults(userGigsCondition: userGigs!)
                        
                        //set to nil so that correct tabs are reset when we edit account
                        //or log into another one
                        userGigs = nil
                    }
                }
            }
        }
        
        //refresh the portfolio when tabs are ready
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshPortfolio"), object: nil)
    }
    
    //UserDefaults to set remembered value
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
}

//Tab Bar Original State
var tabs = [UIViewController]()
