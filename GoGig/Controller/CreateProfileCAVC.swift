//
//  createProfileCAVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 29/08/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase


class CreateProfileCAVC: UIViewController {
    
    @IBOutlet weak var nameBioStack: UIStackView!
    @IBOutlet weak var playGigsButton: UIButton!
    @IBOutlet weak var hireMusiciansButton: UIButton!
    @IBOutlet weak var iWantToLabel: UILabel!
    @IBOutlet weak var usernameField: MyTextField!
    @IBOutlet weak var userBioTextView: MyTextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var musicianIcon: UIImageView!
    @IBOutlet weak var organiserIcon: UIImageView!
    
    var user: User?
    var editingGate = true
    
    var userData: Dictionary<String, Any>?
    
    var email: String?
    var password: String?
    
    var userGigs: Bool?
    
    var placeholder = "Write a bio... |"
    
    var imagePicker: UIImagePickerController?
    var imageID = ""
    var imageAdded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        hideKeyboard()
        
        usernameField.updateCharacterLimit(limit: 50)
        userBioTextView.updatePlaceholder(placeholder: placeholder)
        userBioTextView.text = placeholder
        userBioTextView.textColor = UIColor.lightGray
        //to get profile image from sources
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        //make profile image round with slight border
        profileImageView.layer.borderWidth = 0.1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
    }
    //is part of navigation stack so hide the navigation bar
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        //if editing account
        if editingProfile && editingGate {
            //get the current user data...
            if let uid = Auth.auth().currentUser?.uid {
                DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                    //..as a dictionary
                    let returnedUserData = ["email": returnedUser.email, "bio": returnedUser.bio, "gigs": returnedUser.gigs, "name": returnedUser.name, "picURL": returnedUser.picURL, "website": returnedUser.getWebsite(), "phone": returnedUser.phone, "instagram": returnedUser.getInstagram(), "twitter": returnedUser.getTwitter(), "facebook": returnedUser.getFacebook(), "appleMusic": returnedUser.getAppleMusic(), "spotify": returnedUser.getSpotify()] as [String : Any]
                    self.user = returnedUser
                    //userData is the returnedUserData until changed
                    //auto-fill the UI elements with current user data
                    self.userData = returnedUserData
                    self.usernameField.text = returnedUser.name
                    self.userBioTextView.text = returnedUser.bio
                    self.userGigs = returnedUser.gigs
                    self.email = returnedUser.email
                    self.password = ""
                    if returnedUser.gigs {
                        self.formatGigHireButtons(chosenButton: self.playGigsButton, ignoredButton: self.hireMusiciansButton)
                    } else {
                        self.formatGigHireButtons(chosenButton: self.hireMusiciansButton, ignoredButton: self.playGigsButton)
                    }
                    //editing gate stops user going back in the navigation stack and
                    //their information being automatically filled out again.
                    self.editingGate = false
                }
            }
        }
    }
    
    //MARK: STAGE 1: TYPE OF USER
    
    //set the appearance of the user type buttons
    func formatGigHireButtons(chosenButton: UIButton, ignoredButton: UIButton){
        chosenButton.alpha = 1
        //ignored button will be see-through
        ignoredButton.alpha = 0.5
        //set icons accordingly
        if chosenButton == playGigsButton {
            musicianIcon.alpha = 1
            organiserIcon.alpha = 0.5
            //record type of user
            userGigs = true
        } else {
            musicianIcon.alpha = 0.5
            organiserIcon.alpha = 1
            userGigs = false
        }
        //dont allow user to edit their type of user
        //when editing profile
        if editingProfile {
            iWantToLabel.isHidden = true
            playGigsButton.isHidden = true
            musicianIcon.isHidden = true
            hireMusiciansButton.isHidden = true
            organiserIcon.isHidden = true
        } else {
            iWantToLabel.isHidden = false
            playGigsButton.isHidden = false
            musicianIcon.isHidden = false
            hireMusiciansButton.isHidden = false
            organiserIcon.isHidden = false
        }
    }
    
    @IBAction func userGigs(_ sender: Any) {
        
        formatGigHireButtons(chosenButton: playGigsButton, ignoredButton: hireMusiciansButton)
    }
    @IBAction func userHires(_ sender: Any) {
        
        formatGigHireButtons(chosenButton: hireMusiciansButton, ignoredButton: playGigsButton)
    }
    
    //MARK: STAGE 2: ADD PROFILE PICTURE
    
    //open action sheet to choose or take photo
    @IBAction func addProfilePhoto(_ sender: Any) {
        openPhotoPopup(video: false, imagePicker: imagePicker!, title: "Profile Picture", message: "This picture is seen by other users")
    }
    
    //dismiss the imagePicker once one has been selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //the info dictionary may contain multiple representations of the image. Use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        //set the UIImageView to the image picked
        profileImageView.image = selectedImage
        imageAdded = true
        
        imageID = "\(NSUUID().uuidString).jpg"
        
        //dismiss ImagePicker Controller
        dismiss(animated: true, completion: nil)
    }
    

    
    //MARK: STAGE 3: UPLOAD PROFILE
    
    @IBAction func continueButton(_ sender: Any) {
        //check username
        if let userName = usernameField.text {
            if userName.count >= 2 {
                
                //check Bio, it is optional
                if let userBiography = userBioTextView.text {
                    var userBio = userBiography
                    //so if the text is the default...
                    if userBiography == "Write a bio... |" {
                        //...then just store in database as an empty string
                        userBio = ""
                    }
                    //check necessary data
                    if imageAdded && userGigs != nil {
                        
                        //add to userData and segue
                        self.userData!["name"] = userName
                        self.userData!["bio"] = userBio
                        self.userData!["gigs"] = userGigs
                        
                        self.performSegue(withIdentifier: TO_SOCIAL_LINKS, sender: nil)
                        
                    } else {
                        displayError(title: "Oops", message: "Please provide all necessary information")
                    }
                }
                
            } else {
                displayError(title: "Oops", message: "Please enter your name")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_SOCIAL_LINKS {
            
            //need this line to pass information between view controllers
            let socialLinksCAVC = segue.destination as! SocialLinksCAVC
            
            //changes it
            socialLinksCAVC.userData = self.userData
            socialLinksCAVC.email = self.email
            socialLinksCAVC.password = self.password
            socialLinksCAVC.userGigs = self.userGigs
            socialLinksCAVC.imageID = self.imageID
            socialLinksCAVC.profileImage = self.profileImageView.image
            socialLinksCAVC.user = self.user
        }
    }
}
