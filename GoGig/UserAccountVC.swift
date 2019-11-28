//
//  UserAccountVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 18/12/2018.
//  Copyright © 2018 ChillyDesigns. All rights reserved.
//

//  Profile Pic is distorted
//  User data does not load quickly
//  Post image caching is not very quick

//  Constraints in table view cell

import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class UserAccountVC: UITableViewController {
    
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var addPortfolioBarButton: UIBarButtonItem!
    
    var observingPortfolio = false
    var hideForLoad = true
    
    var user: User?
    var uid: String?
    var portfolioPosts = [PortfolioPost]()
    
    override func viewDidLoad() {
        setupView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPortfolio), name: NSNotification.Name(rawValue: "refreshPortfolio"), object: nil)
        
        //So crash not on initial download??
        if Auth.auth().currentUser != nil {
            refreshPortfolio()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        refreshFCMToken()
    }
    override func viewDidDisappear(_ animated: Bool) {
        //playingAVPlayer?.closePlayer()
        if playingAVPlayer != nil {
            playingAVPlayer!.closePlayer()
        }
    }
    
    //MARK: FETCH DATA
    //We will reuse this VC when we want to look at someone else's profile
    //use did select row at to pass the user uid to this controller
    //if we didn't click on anything when the view appears, use the current user uid
    @objc func refreshPortfolio(){
        
        print("portfolio refreshed")
        
        //User is looking at themself
        //Gate is needed incase user signs in and signs out again
        if uid == nil || accountGateOpen {
            accountGateOpen = false
            uid = Auth.auth().currentUser?.uid //^
        //User is looking at another
        }
        
        if observingPortfolio {
            //hide the settings
            navigationItem.leftBarButtonItem = nil
            //hide the add button
            navigationItem.rightBarButtonItem = nil
        }
        
        DataService.instance.getDBUserProfile(uid: uid!) { (returnedUser) in
            self.user = returnedUser
            self.loadImageCache(url: returnedUser.picURL, isImage: true) { (returnedProfileImage) in
                self.profilePic = returnedProfileImage
                DataService.instance.getDBPortfolioPosts(uid: self.uid!) { (returnedPosts) in
                    self.portfolioPosts = self.quickSort(array:returnedPosts)
                    //print(self.portfolioPosts)
                    //self.portfolioPosts = returnedPosts
                    self.hideForLoad = false
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        let settingsPopup = UIAlertController(title: "Settings", message: "What would you like to do?", preferredStyle: .actionSheet)
        //Go and edit the account
        let editProfileAction = UIAlertAction(title: "Edit profile", style: .default) { (buttonTapped) in
            editingProfile = true
            if let tabBarController = self.tabBarController {
                tabBarController.viewControllers = tabs
                tabGateOpen = true
                accountGateOpen = true
                cardGateOpen = true
                feedGateOpen = true
                observeGateOpen = true
                paginationGateOpen = true
                pushNotificationGateOpen = true
                
                //DEFAULTS.set(nil, forKey: "gigs")
            }
            self.performSegue(withIdentifier: TO_EDIT_PROFILE, sender: nil)
        }
        let logoutAction = UIAlertAction(title: "Log out", style: .destructive) { (buttonTapped) in
            let alertController = UIAlertController(title: "Log out", message: "Are you sure you want to log out of your account?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
            alertController.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (buttonPressed) in
                do {
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        //So does not update account which is not theirs
                        DataService.instance.removeObservers(uid: uid)
                        //Change the FCM token so the iPhone stops receiving notifications
                        DataService.instance.updateDBUserFCMToken(uid: uid, token: "empty_token")
                    }
                    
                    try Auth.auth().signOut()
                    let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginSignupVC") as? LoginSignupVC
                    self.present(loginVC!, animated: true, completion: nil)
                    
                    //When the user logs out we need to return the tab bar to its original state ready for either type of user to log in
                    if let tabBarController = self.tabBarController {
                        tabBarController.viewControllers = tabs
                        tabGateOpen = true
                        accountGateOpen = true
                        cardGateOpen = true
                        feedGateOpen = true
                        observeGateOpen = true
                        paginationGateOpen = true
                        pushNotificationGateOpen = true
                        
                        self.uid = nil
                        
                        DEFAULTS.set(nil, forKey: "gigs")
                    }
                    
                } catch {
                    self.displayError(title: "There was an error", message: "Something went wrong, please try again")
                }
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        settingsPopup.addAction(editProfileAction)
        settingsPopup.addAction(logoutAction)
        settingsPopup.addAction(cancelAction)
        present(settingsPopup, animated: true, completion: nil)
    }
    
    //MARK: USER HEADER CELL
    var profilePic = UIImage(named: "icons8-user") //Have a placeholder image
    func updateUserData(cell: AccountHeaderCell){
        //Set the navigation bar title
        self.navigationController?.navigationBar.topItem?.title = user?.name
        
        //Set the account header cell outlets
        cell.userBioTextView.text = user?.bio
        if user?.gigs == true {
            cell.userTypeLabel.text = "Looking to play"
        } else {
            cell.userTypeLabel.text = "Hiring entertainment"
        }
        
        cell.profilePicView.image = profilePic
        cell.userEmailLabel.text = user?.email
        cell.userPhoneLabel.text = user?.phone
        
        //Signing in and out doesn't bring back hidden icons
        if user?.getFacebook() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.facebookLinkButton, at: 5)
            cell.facebookLinkButton.isEnabled = false
            cell.facebookLinkButton.alpha = 0.0
        } else {
            cell.facebookLinkButton.isEnabled = true
            cell.facebookLinkButton.alpha = 1.0
        }
        if user?.getTwitter() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.twitterLinkButton, at: 5)
            cell.twitterLinkButton.isEnabled = false
            cell.twitterLinkButton.alpha = 0.0
        } else {
            cell.twitterLinkButton.isEnabled = true
            cell.twitterLinkButton.alpha = 1.0
        }
        if user?.getInstagram() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.instagramLinkButton, at: 5)
            cell.instagramLinkButton.isEnabled = false
            cell.instagramLinkButton.alpha = 0.0
        } else {
            cell.instagramLinkButton.isEnabled = true
            cell.instagramLinkButton.alpha = 1.0
        }
        if user?.getWebsite() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.websiteLinkButton, at: 5)
            cell.websiteLinkButton.isEnabled = false
            cell.websiteLinkButton.alpha = 0.0
        } else {
            cell.websiteLinkButton.isEnabled = true
            cell.websiteLinkButton.alpha = 1.0
        }
        if user?.getAppleMusic() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.appleMusicLinkButton, at: 5)
            cell.appleMusicLinkButton.isEnabled = false
            cell.appleMusicLinkButton.alpha = 0.0
        } else {
            cell.appleMusicLinkButton.isEnabled = true
            cell.appleMusicLinkButton.alpha = 1.0
        }
        if user?.getSpotify() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.spotifyLinkButton, at: 5)
            cell.spotifyLinkButton.isEnabled = false
            cell.spotifyLinkButton.alpha = 0.0
        } else {
            cell.spotifyLinkButton.isEnabled = true
            cell.spotifyLinkButton.alpha = 1.0
        }
    }
    
    //MARK: PORTFOLIO POST CELLS
    func updatePostData(cell: AccountPostCell, row: Int) {
        if uid != Auth.auth().currentUser?.uid {
            cell.postMoreButton.isHidden = true
        }
        
        //portfolioPosts[row] means the right post for that cell in the table
        cell.postLocationLabel.text = portfolioPosts[row].location
        
        //If no caption, then hide the text view
        if portfolioPosts[row].caption != "" {
            cell.postCaptionTextView.isHidden = false
            cell.postCaptionTextView.text = portfolioPosts[row].caption
        } else {
            cell.postCaptionTextView.isHidden = true
        }
        //Add a tag to the button so we know what cell the button belongs to when it is tapped
        cell.postMoreButton.tag = row
        
        if portfolioPosts[row].isImage {
            
            cell.postContainerView.removePlayButton()
            cell.postContainerView.loadImageCache(url: portfolioPosts[row].postURL, isImage: portfolioPosts[row].isImage)
            
        } else {
            
            cell.postContainerView.loadImageCache(url: portfolioPosts[row].thumbnailURL, isImage: portfolioPosts[row].isImage)
        }
    }
    
    //To play a video when cell is tapped
    var playingAVPlayer: PostContainerView?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section != 0 { //so no crash when profile tapped
            
            let tappedCell = tableView.cellForRow(at: indexPath) as! AccountPostCell
            
            //If it's a video and tapped
            if !portfolioPosts[indexPath.section - 1].isImage {
                
                //Remove the thumbnail and play the video
                
                tappedCell.postContainerView.addVideo(url: portfolioPosts[indexPath.section - 1].postURL, fit: false)
                
                tappedCell.postContainerView.playPlayer()
                playingAVPlayer = tappedCell.postContainerView
                
            }
        }
    }
    
    //MARK: MORE (DELETION)
    @IBAction func postMoreButton(_ sender: UIButton) {
        
        let row = sender.tag
        
        let morePopup = UIAlertController(title: "More", message: "What would you like to do with your post?", preferredStyle: .actionSheet)
        let deletePostAction = UIAlertAction(title: "Delete Post", style: .destructive) { (buttonTapped) in
            
            //Delete the post from Database and from Storage
            DataService.instance.deleteDBPortfolioPosts(uid: self.user!.uid, postID: self.portfolioPosts[row].getid())
            DataService.instance.deleteSTFile(uid: self.user!.uid, directory: "portfolioPost", fileID: self.portfolioPosts[row].getid())
            if !(self.portfolioPosts[row].isImage) {
                DataService.instance.deleteSTFile(uid: self.user!.uid, directory: "portfolioThumbnail", fileID: self.portfolioPosts[row].getid())
            }
            self.portfolioPosts.remove(at: row)
            self.refreshPortfolio()
        }
        let cancelPostAction = UIAlertAction(title: "Cancel", style: .cancel) { (buttonTapped) in
            print("operation aborted")
        }
        
        morePopup.addAction(deletePostAction)
        morePopup.addAction(cancelPostAction)
        present(morePopup, animated: true, completion: nil)
    }
    
    //Refresh the FCM Token for push notifications
    func refreshFCMToken() {
        if deviceFCMToken != nil && pushNotificationGateOpen == true {
            if let uid = Auth.auth().currentUser?.uid {
                DataService.instance.updateDBUserFCMToken(uid: uid, token: deviceFCMToken!)
                pushNotificationGateOpen = false
            }
        }
    }
    
    //MARK: SOCIAL LINKS
    @IBAction func facebookLink(_ sender: Any) {
        let fbPageID = user?.getFacebook()
        //Horham Baptist Church (Business account): 1837812439827573
        if let appURL = URL(string: "fb://profile/\(fbPageID!)") {
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                // if Facebook app is not installed, open URL inside Safari
                let webURL = URL(string: "http://www.facebook.com/\(fbPageID!)")!
                if application.canOpenURL(webURL) {
                    application.open(webURL)
                } else {
                    displayError(title: "", message: "Couldn't open Facebook account")
                }
            }
        }
    }
    @IBAction func twitterLink(_ sender: Any) {
        let username =  user?.getTwitter()
        if let appURL = URL(string: "twitter://user?screen_name=\(username!)") {
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                // if Instagram app is not installed, open URL inside Safari
                let webURL = URL(string: "https://twitter.com/\(username!)")!
                if application.canOpenURL(webURL){
                    application.open(webURL)
                } else {
                    displayError(title: "", message: "Couldn't open Twitter account")
                }
            }
        }
    }
    @IBAction func instagramLink(_ sender: Any) {
        let username =  user?.getInstagram()
        if let appURL = URL(string: "instagram://user?username=\(username!)") {
            let application = UIApplication.shared
            
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                // if Instagram app is not installed, open URL inside Safari
                let webURL = URL(string: "https://instagram.com/\(username!)")!
                if application.canOpenURL(webURL){
                    application.open(webURL)
                } else {
                    displayError(title: "", message: "Couldn't open Instagram account")
                }
            }
        }
    }
    @IBAction func websiteLink(_ sender: Any) {
        let userWebsite = user?.getWebsite()
        if let webURL = URL(string: userWebsite!) {
            let application = UIApplication.shared
            if application.canOpenURL(webURL) {
                application.open(webURL)
            }
        } else {
            displayError(title: "", message: "Couldn't find website")
        }
    }
    @IBAction func appleMusicLink(_ sender: Any) {
        let userStreaming = user?.getAppleMusic()
        if let webURL = URL(string: userStreaming!) {
            let application = UIApplication.shared
            if application.canOpenURL(webURL) {
                application.open(webURL)
            }
        } else {
            displayError(title: "", message: "Couldn't find Apple Music profile")
        }
    }
    @IBAction func spotifyLink(_ sender: Any) {
        let userStreaming = user?.getSpotify()
        if let webURL = URL(string: userStreaming!) {
            let application = UIApplication.shared
            if application.canOpenURL(webURL) {
                application.open(webURL)
            }
        } else {
            displayError(title: "", message: "Couldn't find Spotify profile")
        }
    }
}
var deviceFCMToken: String?

