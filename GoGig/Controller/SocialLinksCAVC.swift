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
    let loadingSpinner = SpinnerViewController()

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
        websiteField.updateCharacterLimit(limit: 100)
        instagramField.updateCharacterLimit(limit: 30)
        twitterField.updateCharacterLimit(limit: 15)
        facebookField.updateCharacterLimit(limit: 20)
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    //view Did Appear is only called when in a navigation controller
    override func viewDidAppear(_ animated: Bool) {
        //autofill fields when editing
        if editingProfile == true && user != nil {
            websiteField.text = user?.getWebsite()
            phoneNumberField.text = user?.phone
            instagramField.text = user?.getInstagram()
            twitterField.text = user?.getTwitter()
            facebookField.text = user?.getFacebook()
        }
    }
    
    //MARK: STAGE 4: UPLOAD PROFILE PICTURE (If event organiser)
    
    //put the profile pic in firebase storage
    func picUpload(uid: String, handler: @escaping (_ url: URL) -> ()) {

        if let userPic = profileImage {
            //upload the picture to Firebase
            DataService.instance.updateSTPic(uid: uid, directory: "profilePic", imageContent: userPic, imageID: imageID, uploadComplete: { (success, error) in
                if error != nil {
                    //allow user to interact with screen again
                    self.removeSpinnerView(self.loadingSpinner)
                    self.displayError(title: "There was an Error", message: error!.localizedDescription)

                } else {
                    //get the URL of the stored image, to store in the database
                    DataService.instance.getSTURL(uid: uid, directory: "profilePic", imageID: self.imageID) { (returnedURL) in

                        handler(returnedURL)
                    }
                }
            })
        }
    }
    
    //MARK: STAGE 5: SIGN UP IF ORGANISER, PROGRESS IF MUSICIAN
    
    @IBAction func continueButton(_ sender: Any) {
        //all social links are optional inputs
        //but flag if an input does not follow validation rules
        var continueFine = true
        if let userWebsite = websiteField.text {
            //do checks
            if (userWebsite.contains(".") && userWebsite.count > 5) || userWebsite == "" {
                //add to dictionary if okay
                userData!["website"] = userWebsite
            } else {
                //if not okay then cannot continue
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
        if let userInstagramStr = instagramField.text {
            //make variable from constant
            var userInstagram = userInstagramStr
            //check first char
            if userInstagram != "" && userInstagram.count > 1 && userInstagram[userInstagram.startIndex] == "@" {
                //make a substring (remove the @)
                userInstagram = userInstagram.substring(start: 1, end: userInstagram.count)
            }
            if (!userInstagram.contains("@") && !userInstagram.contains(" ")) || userInstagram == "" {
                userData!["instagram"] = userInstagram
            } else {
                displayError(title: "Oops", message: "Please enter a valid Instagram username (optional)")
                continueFine = false
            }
        }
        if let userTwitterStr = twitterField.text {
            //make variable from constant
            var userTwitter = userTwitterStr
            //check first char
            if userTwitter != "" && userTwitter.count > 1 && userTwitter[userTwitter.startIndex] == "@" {
                //make a substring (remove the @)
                userTwitter = userTwitter.substring(start: 1, end: userTwitter.count)
            }
            if (!userTwitter.contains("@") && !userTwitter.contains(" ")) || userTwitter == "" {
                userData!["twitter"] = userTwitter
            } else {
                displayError(title: "Oops", message: "Please enter a valid Twitter username (optional)")
                continueFine = false
            }
        }
        if let userFacebookID = facebookField.text {
            if (userFacebookID.count > 10 && !userFacebookID.contains(" ")) || userFacebookID == "" {
                userData!["facebook"] = userFacebookID
            } else {
                displayError(title: "Oops", message: "Please enter a valid Facebook page ID (optional)")
                continueFine = false
            }
        }
        //if social links are okay
        if continueFine {
            //if musician, allow them to add Spotify and Apple Music
            if userGigs! {
                
                self.performSegue(withIdentifier: TO_MUSIC_LINKS, sender: nil)
                
            //organiser is done
            } else {
                //stop user interaction
                self.createSpinnerView(self.loadingSpinner)
                if editingProfile == false {
                    //sign the user up
                    AuthService.instance.registerUser(withEmail: email!, andPassword: password!, userCreationComplete: { (success, error) in
                        if error != nil {
                            //allow user interaction again
                            self.removeSpinnerView(self.loadingSpinner)
                            //display a UIAlertController if something goes wrong
                            self.displayError(title: "There was an Error", message: error!.localizedDescription)
                            
                        } else {
                            
                            //successfuly registered and added to database
                            //now log user in
                            AuthService.instance.loginUser(withEmail: self.email!, andPassword: self.password!, loginComplete: { (success, nil) in })
                            //send their profile data to Database
                            self.updateUserData()
                        }
                    })
                    
                } else {
                    //sser is editing their profile, not creating an account
                    self.updateUserData()
                }
            }
        }
    }
    
    func updateUserData(){
        if let uid = Auth.auth().currentUser?.uid {
            //upload the pic to cloud storage
            self.picUpload(uid: uid) { (returnedURL) in
                
                self.userData!["picURL"] = returnedURL.absoluteString
                DataService.instance.updateDBUserProfile(uid: uid, userData: self.userData!) { (complete) in
                    
                    if complete {
                        
                        accountGateOpen = true
                        
                        self.removeSpinnerView(self.loadingSpinner)
                        
                        if !editingProfile {
                            //creating account
                            self.performSegue(withIdentifier: TO_MAIN, sender: nil)
                        } else {
                            self.dismiss(animated: true)
                            //done with editing refresh the tab bar
                            editingProfile = false
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshTabs"), object: nil)
                        }
                        //update FCM Token for push notifications
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
            
            //need this line to pass information between view controllers
            let musicLinksCAVC = segue.destination as! MusicLinksCAVC
            
            //changes it
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
            //done with editing
            editingProfile = false
            
        }
    }
}
