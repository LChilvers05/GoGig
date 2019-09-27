//
//  SocialLinksCAVC.swift
//  
//
//  Created by Lee Chilvers on 29/08/2019.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseMessaging
import FirebaseInstanceID

class SocialLinksCAVC: UIViewController {
    
    @IBOutlet weak var fieldsStack: UIStackView!
    @IBOutlet weak var phoneNumberField: MyTextField!
    @IBOutlet weak var websiteField: MyTextField!
    @IBOutlet weak var instagramField: MyTextField!
    @IBOutlet weak var twitterField: MyTextField!
    @IBOutlet weak var facebookField: MyTextField!

    var user: User?
    
    var userData: Dictionary<String, Any>?
    
    var email: String?
    var password: String?
    
    var userGigs: Bool?
    
    var imageID = ""
    var profileImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        hideKeyboard()
        phoneNumberField.updateCharacterLimit(limit: 16)
        websiteField.updateCharacterLimit(limit: 64)
        instagramField.updateCharacterLimit(limit: 30)
        twitterField.updateCharacterLimit(limit: 15)
        //facebookField.updateCharacterLimit(limit: 20)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //Only reached if placed in navigation controller
    override func viewDidAppear(_ animated: Bool) {
        print("reached1")
        if editingProfile == true && user != nil {
            print("reached2")
            websiteField.text = user?.getWebsite()
            phoneNumberField.text = user?.phone
            instagramField.text = user?.getInstagram()
            twitterField.text = user?.getTwitter()
            facebookField.text = user?.getFacebook()
        }
    }
    
    //MARK: STAGE 4: UPLOAD PROFILE PICTURE (If event organiser)
    
    //Put the profile pic in firebase storage
    func picUpload(uid: String, handler: @escaping (_ url: URL) -> ()) {

        if let userPic = profileImage {

            DataService.instance.updateSTPic(uid: uid, directory: "profilePic", imageContent: userPic, imageID: imageID, uploadComplete: { (success, error) in
                if error != nil {

                    self.displayError(title: "There was an Error", message: error!.localizedDescription)

                } else {

                    DataService.instance.getSTURL(uid: uid, directory: "profilePic", imageID: self.imageID) { (returnedURL) in

                        handler(returnedURL)

                    }
                }
            })
        }
    }
    
    //MARK: STAGE 5: SIGN UP IF ORGANISER, PROGRESS IF MUSICIAN
    
    @IBAction func continueButton(_ sender: Any) {
        var continueFine = true
        if let userWebsite = websiteField.text {
            if (userWebsite.contains(".") && userWebsite.count > 5) || userWebsite == "" {
                userData!["website"] = userWebsite
            } else {
                displayError(title: "Oops", message: "Please enter a valid website (optional)")
                continueFine = false
            }
        }
        if let userPhoneNumber = phoneNumberField.text {
            if userPhoneNumber.count > 10 || userPhoneNumber == "" {
                userData!["phone"] = userPhoneNumber
            } else {
                displayError(title: "Oops", message: "Please enter a valid phone number (optional)")
                continueFine = false
            }
        }
        if let userInstagram = instagramField.text {
            if (!userInstagram.contains("@") && !userInstagram.contains(" ")) || userInstagram == "" {
                userData!["instagram"] = userInstagram
            } else {
                displayError(title: "Oops", message: "Please enter a valid Instagram username (optional)")
                continueFine = false
            }
        }
        if let userTwitter = twitterField.text {
            if (!userTwitter.contains("@") && !userTwitter.contains(" ")) || userTwitter == "" {
                userData!["twitter"] = userTwitter
            } else {
                displayError(title: "Oops", message: "Please enter a valid Twitter username (optional)")
                continueFine = false
            }
        }
//        if let userFacebookID = facebookField.text {
//            if userFacebookID.count > 10 {
//                userData!["facebookID"] = userFacebookID
//            } else {
//                displayError(title: "Oops", message: "Please enter a valid Facebook page ID (optional)")
//                continueFine = false
//            }
//        }
        
        if continueFine {
            if userGigs! {
                
                self.performSegue(withIdentifier: TO_MUSIC_LINKS, sender: nil)
                
            //Organiser is done
            } else {
                
                if editingProfile == false {
                    //Sign the user up
                    AuthService.instance.registerUser(withEmail: email!, andPassword: password!, userCreationComplete: { (success, error) in
                        if error != nil {
                            
                            self.displayError(title: "There was an Error", message: error!.localizedDescription)
                            
                        } else {
                            
                            //Successfuly registered and added to database
                            //Now log user in
                            AuthService.instance.loginUser(withEmail: self.email!, andPassword: self.password!, loginComplete: { (success, nil) in })
                            
                            self.updateUserData()
                        }
                    })
                    
                } else {
                    //User is editing their profile, not creating an account
                    self.updateUserData()
                }
            }
        }
    }
    
    func updateUserData(){
        if let uid = Auth.auth().currentUser?.uid {
            //Upload the pic to cloud storage
            self.picUpload(uid: uid) { (returnedURL) in
                
                self.userData!["picURL"] = returnedURL.absoluteString
                
                DataService.instance.updateDBUserProfile(uid: uid, userData: self.userData!) { (complete) in
                    
                    if complete {
                        
                        accountGateOpen = true
                        if !editingProfile {
                            //creating account
                            self.performSegue(withIdentifier: TO_MAIN, sender: nil)
                        } else {
                            self.dismiss(animated: true)
                            editingProfile = false
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshTabs"), object: nil)
                        }
                        //Update FCM Token for push notifications
                        InstanceID.instanceID().instanceID { (result, error) in
                            if let error = error {
                                print("Error fetching remote instance ID: \(error)")
                            } else if let result = result {
                                print("Remote instance ID token: \(result.token)")
                                deviceFCMToken = result.token
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_MUSIC_LINKS {
            
            //Need this line to pass information between view controllers
            let musicLinksCAVC = segue.destination as! MusicLinksCAVC
            
            //Changes it
            musicLinksCAVC.userData = self.userData
            musicLinksCAVC.email = self.email
            musicLinksCAVC.password = self.password
            musicLinksCAVC.userGigs = self.userGigs
            musicLinksCAVC.imageID = self.imageID
            musicLinksCAVC.profileImage = self.profileImage
            musicLinksCAVC.user = self.user
            
        } else if segue.identifier == TO_MAIN {
            
            let tabBarController = segue.destination as! TabBarController
            tabBarController.userGigs = self.userGigs
            editingProfile = false
            
        }
    }
}
