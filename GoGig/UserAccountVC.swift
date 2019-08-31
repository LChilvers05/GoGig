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
    
    var user: User?
    var uid: String?
    var portfolioPosts = [PortfolioPost]()
    
    override func viewDidLoad() {
        
        setupView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPortfolio), name: NSNotification.Name(rawValue: "refreshPortfolio"), object: nil)
        refreshPortfolio()
    }
    override func viewDidAppear(_ animated: Bool) {
        refreshFCMToken()
    }
    
    //MARK: FETCH DATA
    //We will reuse this VC when we want to look at someone else's profile
    //use did select row at to pass the user uid to this controller
    //if we didn't click on anything when the view appears, use the current user uid
    @objc func refreshPortfolio(){
        
        //User is looking at themself
        //Gate is needed incase user signs in and signs out again
        if uid == nil || accountGateOpen {
            accountGateOpen = false
            uid = Auth.auth().currentUser?.uid //^
        //User is looking at another
        } else {
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
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func tempSignOut(_ sender: Any) {
        
        let logoutPopup = UIAlertController(title: "Logout?", message: "Are you sure you want to sign out of your account?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (buttonTapped) in
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
                
                    DEFAULTS.set(nil, forKey: "gigs")
                }
                
            } catch {
                
                self.displayError(title: "There was an error", message: "Something went wrong, please try again")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (buttonTapped) in
            print("operation aborted")
        }
        
        logoutPopup.addAction(logoutAction)
        logoutPopup.addAction(cancelAction)
        present(logoutPopup, animated: true, completion: nil)
    }
    
    //MARK: USER HEADER CELL
    var profilePic = UIImage(named: "icons8-user") //Have a placeholder image
    func updateUserData(cell: AccountHeaderCell){
        if uid != Auth.auth().currentUser?.uid {
            cell.signOutButton.isHidden = true
        }
        
        //Set the navigation bar title
        self.navigationController?.navigationBar.topItem?.title = user?.name
        
        //Set UI
        cell.userBioTextView.text = user?.bio
        if user?.gigs == true {
            cell.userTypeLabel.text = "Looking to play"
        } else {
            cell.userTypeLabel.text = "Hiring entertainment"
        }
        
        cell.profilePicView.image = profilePic
        cell.userEmailLabel.text = user?.email
        cell.userPhoneLabel.text = user?.phone
        
        if user?.getFacebook() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.facebookLinkButton, at: 5)
            cell.facebookLinkButton.isEnabled = false
            cell.facebookLinkButton.alpha = 0.0
        }
        if user?.getTwitter() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.twitterLinkButton, at: 5)
            cell.twitterLinkButton.isEnabled = false
            cell.twitterLinkButton.alpha = 0.0
        }
        if user?.getInstagram() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.instagramLinkButton, at: 5)
            cell.instagramLinkButton.isEnabled = false
            cell.instagramLinkButton.alpha = 0.0
        }
        if user?.getWebsite() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.websiteLinkButton, at: 5)
            cell.websiteLinkButton.isEnabled = false
            cell.websiteLinkButton.alpha = 0.0
        }
        if user?.getAppleMusic() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.appleMusicLinkButton, at: 5)
            cell.appleMusicLinkButton.isEnabled = false
            cell.appleMusicLinkButton.alpha = 0.0
        }
        if user?.getSpotify() == "" {
            cell.socialLinkStackView.insertArrangedSubview(cell.spotifyLinkButton, at: 5)
            cell.spotifyLinkButton.isEnabled = false
            cell.spotifyLinkButton.alpha = 0.0
        }
    }
    
    //MARK: PORTFOLIO POST CELLS
    func updatePostData(cell: AccountPostCell, row: Int) {
        if uid != Auth.auth().currentUser?.uid {
            cell.postMoreButton.isHidden = true
        }
        
        cell.postLocationLabel.text = portfolioPosts[row].location
        cell.postCaptionTextView.text = portfolioPosts[row].caption
        cell.postMoreButton.tag = row
        
        if portfolioPosts[row].isImage {
            
            cell.postContainerView.loadImageCache(url: portfolioPosts[row].postURL, isImage: portfolioPosts[row].isImage)
            
        } else {
            
            cell.postContainerView.loadImageCache(url: portfolioPosts[row].thumbnailURL, isImage: portfolioPosts[row].isImage)
        }
    }
    
    //To play a video when cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section != 0 { //so no crash when profile tapped
            
            let tappedCell = tableView.cellForRow(at: indexPath) as! AccountPostCell
            
            //If it's a video and tapped
            if !portfolioPosts[indexPath.section - 1].isImage {
                
                //Remove the thumbnail and play the video
                
                tappedCell.postContainerView.addVideo(url: portfolioPosts[indexPath.section - 1].postURL, fit: false)
                
                tappedCell.postContainerView.playPlayer()
                
            }
        }
    }
    
    //MARK: MORE (DELETION)
    @IBAction func postMoreButton(_ sender: UIButton) {
        
        let row = sender.tag
        
        let morePopup = UIAlertController(title: "more", message: "", preferredStyle: .actionSheet)
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
        let cancelPostAction = UIAlertAction(title: "Cancel", style: .default) { (buttonTapped) in
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
//        UIApplication.tryURL(urls: [
//            "fb://profile/1837812439827573", // App
//            "http://www.facebook.com/1837812439827573" // Website if app fails
//            ])
    }
    @IBAction func twitterLink(_ sender: Any) {
        let username =  user?.getTwitter()
        if let appURL = URL(string: "twitter://user?screen_name=\(username!)") {
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                // if Instagram app is not installed, open URL inside Safari
                let webURL = URL(string: "https://instagram.com/\(username!)")!
                application.open(webURL)
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
                application.open(webURL)
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

