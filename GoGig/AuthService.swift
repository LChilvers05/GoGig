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
    
    //using a singleton
    static let instance = AuthService()
    
    //subscribe the user to Firebase Authentication
    func registerUser(withEmail email: String, andPassword password: String, userCreationComplete: @escaping ( _ status: Bool, _ error: Error?) -> ()) {
        
        //adds user to Auth list
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            //if there is no result of creating user
            guard let user = authResult?.user else {
                //complete as error
                userCreationComplete(false, error)
                
                return
            }
            
            //adds user to the database
            let userData = ["provider": user.providerID, "email": user.email] //provider = Firebase/Facebook/Google/Email
            //add this userData to Database
            DataService.instance.createDBUser(uid: user.uid , userData: userData as Dictionary<String, Any>)
            //complete as no error
            userCreationComplete(true, nil)
        }
    }
    //Log the user in with Firebase Authentication
    func loginUser(withEmail email: String, andPassword password: String, loginComplete: @escaping ( _ status: Bool, _ error: Error?) -> ()) {
        //sign them in
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            //if there is an error signing in
            if error != nil {
                //complete with error
                loginComplete(false, error)
                return
            }
            //complete with no error
            loginComplete(true, nil)
        }
    }
    
    //MARK: USER DEFAULTS
    //To keep user logged in
//    let defaults = UserDefaults.standard
//
//    var isLoggedIn: Bool {
//        get {
//            //get the Boolean of logged in
//            return defaults.bool(forKey: LOGGED_IN_KEY)
//        }
//        set {
//            //set the Boolean of logged in
//            defaults.set(newValue, forKey: LOGGED_IN_KEY)
//        }
//    }
//
//    var userEmail: Bool {
//        get {
//
//            return defaults.bool(forKey: USER_EMAIL)
//        }
//        set {
//
//            defaults.set(newValue, forKey: USER_EMAIL)
//        }
//    }
}

