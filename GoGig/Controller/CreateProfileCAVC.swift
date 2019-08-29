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
    
    @IBOutlet weak var playGigsButton: UIButton!
    @IBOutlet weak var hireMusiciansButton: UIButton!
    @IBOutlet weak var usernameField: MyTextField!
    @IBOutlet weak var userBioTextView: MyTextView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var musicianIcon: UIImageView!
    @IBOutlet weak var organiserIcon: UIImageView!
    
    var editingProfile = false
    
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
        hideKeyboard()
        usernameField.updateCharacterLimit(limit: 50)
        userBioTextView.updatePlaceholder(placeholder: placeholder)
        userBioTextView.text = placeholder
        userBioTextView.textColor = UIColor.lightGray
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        
        profileImageView.layer.borderWidth = 0.1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: STAGE 1: TYPE OF USER
    
    func formatGigHireButtons(chosenButton: UIButton, ignoredButton: UIButton){
        
        chosenButton.alpha = 1
        ignoredButton.alpha = 0.5
        if chosenButton == playGigsButton {
            musicianIcon.alpha = 1
            organiserIcon.alpha = 0.5
        } else {
            musicianIcon.alpha = 0.5
            organiserIcon.alpha = 1
        }
    }
    
    @IBAction func userGigs(_ sender: Any) {
        userGigs = true
        formatGigHireButtons(chosenButton: playGigsButton, ignoredButton: hireMusiciansButton)
    }
    @IBAction func userHires(_ sender: Any) {
        userGigs = false
        formatGigHireButtons(chosenButton: hireMusiciansButton, ignoredButton: playGigsButton)
    }
    
    //MARK: STAGE 2: ADD PROFILE PICTURE
    @IBAction func addProfilePhoto(_ sender: Any) {
        openPhotoPopup(video: false, imagePicker: imagePicker!, title: "Profile Picture", message: "This picture is seen by other users")
    }
    
    //Dismiss the imagePicker once one has been selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. Use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        //Set the UIImageView to the image picked
        profileImageView.image = selectedImage
        imageAdded = true
        
        imageID = "\(NSUUID().uuidString).jpg"
        
        //Dismiss ImagePicker Controller
        dismiss(animated: true, completion: nil)
    }
    

    
    //MARK: STAGE 3: UPLOAD PROFILE
    
    @IBAction func continueButton(_ sender: Any) {
        //check username
        if let userName = usernameField.text {
            if userName.count >= 2 {
                
                //check bio
                if let userBiography = userBioTextView.text {
                    var userBio = userBiography
                    if userBiography == "Write a bio... |" {
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
            
            //Need this line to pass information between view controllers
            let socialLinksCAVC = segue.destination as! SocialLinksCAVC
            
            //Changes it
            socialLinksCAVC.userData = self.userData
            socialLinksCAVC.email = self.email
            socialLinksCAVC.password = self.password
            socialLinksCAVC.userGigs = self.userGigs
            socialLinksCAVC.imageID = self.imageID
            socialLinksCAVC.profileImage = self.profileImageView.image
            socialLinksCAVC.editingProfile = self.editingProfile
            
        }
    }
}
