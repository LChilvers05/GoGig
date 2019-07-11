//
//  FIRAuthService.swift
//  GoGig
//
//  Created by Lee Chilvers on 26/01/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthService {
    
    static let instance = AuthService()
    
    func registerUser(withEmail email: String, andPassword password: String, userCreationComplete: @escaping ( _ status: Bool, _ error: Error?) -> ()) {
        
        //Adds user to Auth list
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard let user = authResult?.user else {
                
                userCreationComplete(false, error)
                
                return
            }
            
            //Adds user to the database
            let userData = ["provider": user.providerID, "email": user.email] //Facebook/Google/Email
            
            DataService.instance.createDBUser(uid: user.uid , userData: userData as Dictionary<String, Any>)
            userCreationComplete(true, nil)
        }
    }
    
    func loginUser(withEmail email: String, andPassword password: String, loginComplete: @escaping ( _ status: Bool, _ error: Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error != nil {
                loginComplete(false, error)
                return
            }
            
            loginComplete(true, nil)
        }
    }
    
    //Might not need these anymore?
    
    //MARK: USER DEFAULTS
    //To keep user logged in
    
    let defaults = UserDefaults.standard
    
    var isLoggedIn: Bool {
        get {
            
            return defaults.bool(forKey: LOGGED_IN_KEY)
        }
        set {
            
            defaults.set(newValue, forKey: LOGGED_IN_KEY)
        }
    }
    
    var userEmail: Bool {
        get {
            
            return defaults.bool(forKey: USER_EMAIL)
        }
        set {
            
            defaults.set(newValue, forKey: USER_EMAIL)
        }
    }
}

