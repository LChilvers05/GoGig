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
    
    //keep track of user viewing someone else's portfolio or not
    var observingPortfolio = false
    var hideForLoad = true
    
    var user: User?
    var uid: String?
    var portfolioPosts = [PortfolioPost]()
    
    override func viewDidLoad() {
        setupView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPortfolio), name: NSNotification.Name(rawValue: "refreshPortfolio"), object: nil)
        
        //prevents crash if we get to this view without a logged in user
        if Auth.auth().currentUser != nil {
            refreshPortfolio()
        }
    }
    //refresh token for push notifications
    override func viewDidAppear(_ animated: Bool) {
        refreshFCMToken()
    }
    //had issue where audio was heard after a segue
    override func viewDidDisappear(_ animated: Bool) {
        //close player when view dissapears
        if playingAVPlayer != nil {
            playingAVPlayer!.closePlayer()
        }
    }
    
    //MARK: FETCH DATA
    //reuse this VC when we want to look at someone else's profile
    //if we didn't click on anything when the view appears, use the current user uid
    @objc func refreshPortfolio(){
        
        //user is looking at themself
        //gate is needed incase user signs in and signs out again
        if uid == nil || accountGateOpen {
            accountGateOpen = false
            uid = Auth.auth().currentUser?.uid
        //user is looking at another
        }
        
        //when observing
        if observingPortfolio {
            //hide the settings
            navigationItem.leftBarButtonItem = nil
            //hide the add post button
            navigationItem.rightBarButtonItem = nil
        }
        
        //get the profile data
        DataService.instance.getDBUserProfile(uid: uid!) { (returnedUser) in
            //set the user who owns the portfolio
            self.user = returnedUser
            //load profile picture (from cache or download)
            self.loadImageCache(url: returnedUser.picURL, isImage: true) { (returnedProfileImage) in
                self.profilePic = returnedProfileImage
                DataService.instance.getDBPortfolioPosts(uid: self.uid!) { (returnedPosts) in
                    //quick sort the posts by reverse chronological
                    self.portfolioPosts = self.quickSort(array:returnedPosts)
                    //show profile
                    self.hideForLoad = false
                    //show all the data in table view
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func settingsButton(_ sender: Any) {
        let settingsPopup = UIAlertController(title: "Settings", message: "What would you like to do?", preferredStyle: .actionSheet)
        //go and edit the account
        let editProfileAction = UIAlertAction(title: "Edit profile", style: .default) { (buttonTapped) in
            editingProfile = true
            if let tabBarController = self.tabBarController {
                tabBarController.viewControllers = tabs
                tabGateOpen = true //Reset tabs
                accountGateOpen = true //Reset portfolio refresh
                cardGateOpen = true //Reset find gig card refresh
                feedGateOpen = true //Reset activity feed refresh
                observeGateOpen = true //Reset feed observers
                paginationGateOpen = true //Reset activity feed pagination
                pushNotificationGateOpen = true
            }
            self.performSegue(withIdentifier: TO_EDIT_PROFILE, sender: nil)
        }
        //go and log out of the account
        let logoutAction = UIAlertAction(title: "Log out", style: .destructive) { (buttonTapped) in
            //provide a double check
            let alertController = UIAlertController(title: "Log out", message: "Are you sure you want to log out of your account?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
            alertController.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { (buttonPressed) in
                do {
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        //so does not see things in account which is not theirs
                        DataService.instance.removeObservers(uid: uid)
                        //change the FCM token so the iPhone stops receiving notifications
                        DataService.instance.updateDBUserFCMToken(uid: uid, token: "empty_token")
                    }
                    
                    //sign them out and present the log in page
                    try Auth.auth().signOut()
                    let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginSignupVC") as? LoginSignupVC
                    self.present(loginVC!, animated: true, completion: nil)
                    
                    //when the user logs out we need to return the tab bar to its original state ready for either type of user to log in
                    if let tabBarController = self.tabBarController {
                        //reset tabs
                        tabBarController.viewControllers = tabs
                        tabGateOpen = true
                        accountGateOpen = true
                        cardGateOpen = true
                        feedGateOpen = true
                        observeGateOpen = true
                        paginationGateOpen = true
                        pushNotificationGateOpen = true
                        
                        self.uid = nil
                        //set defaults back to normal
                        //do not know what type of user will log in next
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
    var profilePic = UIImage(named: "icons8-user") //have a placeholder image
    func updateUserData(cell: AccountHeaderCell){
        //set the navigation bar title to username
        self.navigationController?.navigationBar.topItem?.title = user?.name
        
        //set the account header cell outlets
        cell.userBioTextView.text = user?.bio
        if user?.gigs == true {
            cell.userTypeLabel.text = "Looking to play"
        } else {
            cell.userTypeLabel.text = "Hiring entertainment"
        }
        
        cell.profilePicView.image = profilePic
        cell.userEmailLabel.text = user?.email
        cell.userPhoneLabel.text = user?.phone
        
        //if user hasn't got Facebook
        if user?.getFacebook() == "" {
            //put it at the right of the horizontal stack
            cell.socialLinkStackView.insertArrangedSubview(cell.facebookLinkButton, at: 5)
            //disable the button
            cell.facebookLinkButton.isEnabled = false
            //and hide it
            cell.facebookLinkButton.alpha = 0.0
        //has facebook
        } else {
            //enable it
            cell.facebookLinkButton.isEnabled = true
            //show it
            cell.facebookLinkButton.alpha = 1.0
        }
        //same for Twitter etc
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
        //if observing
        if uid != Auth.auth().currentUser?.uid {
            //stop user deleting the post
            cell.postMoreButton.isHidden = true
        }
        
        //portfolioPosts[row] means the right post for that cell in the table
        cell.postLocationLabel.text = portfolioPosts[row].location
        
        //if no caption, then hide the text view
        if portfolioPosts[row].caption != "" {
            cell.postCaptionTextView.isHidden = false
            cell.postCaptionTextView.text = portfolioPosts[row].caption
        } else {
            cell.postCaptionTextView.isHidden = true
        }
        //add a tag to the button so we know what cell the button belongs to when it is tapped
        cell.postMoreButton.tag = row
        
        //load image from cache or download
        if portfolioPosts[row].isImage {
            
            cell.postContainerView.removePlayButton()
            cell.postContainerView.loadImageCache(url: portfolioPosts[row].postURL, isImage: portfolioPosts[row].isImage)
        //load video thumbnail from cache or download
        } else {
            
            cell.postContainerView.loadImageCache(url: portfolioPosts[row].thumbnailURL, isImage: portfolioPosts[row].isImage)
        }
    }
    
    //to play a video when cell is tapped
    var playingAVPlayer: PostContainerView?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section != 0 { //so no crash when profile tapped
            
            let tappedCell = tableView.cellForRow(at: indexPath) as! AccountPostCell
            
            //if it's a video and tapped
            if !portfolioPosts[indexPath.section - 1].isImage {
                
                //remove the thumbnail and play the video
                
                tappedCell.postContainerView.addVideo(url: portfolioPosts[indexPath.section - 1].postURL, fit: false)
                
                tappedCell.postContainerView.playPlayer()
                playingAVPlayer = tappedCell.postContainerView
                
            }
        }
    }
    
    //MARK: MORE (DELETION)
    
    @IBAction func postMoreButton(_ sender: UIButton) {
        //learn cell row from the button pressed
        let row = sender.tag
        //ask user if they want to delete
        let morePopup = UIAlertController(title: "More", message: "What would you like to do with your post?", preferredStyle: .actionSheet)
        let deletePostAction = UIAlertAction(title: "Delete Post", style: .destructive) { (buttonTapped) in
            
            //delete the post from Database and from Storage
            DataService.instance.deleteDBPortfolioPosts(uid: self.user!.uid, postID: self.portfolioPosts[row].getid())
            DataService.instance.deleteSTFile(uid: self.user!.uid, directory: "portfolioPost", fileID: self.portfolioPosts[row].getid())
            if !(self.portfolioPosts[row].isImage) {
                DataService.instance.deleteSTFile(uid: self.user!.uid, directory: "portfolioThumbnail", fileID: self.portfolioPosts[row].getid())
            }
            //remove locally
            self.portfolioPosts.remove(at: row)
            //reload table view to reflect the change
            self.refreshPortfolio()
        }
        let cancelPostAction = UIAlertAction(title: "Cancel", style: .cancel) { (buttonTapped) in
            print("operation aborted")
        }
        
        morePopup.addAction(deletePostAction)
        morePopup.addAction(cancelPostAction)
        present(morePopup, animated: true, completion: nil)
    }
    
    //refresh the FCM Token for push notifications
    func refreshFCMToken() {
        if deviceFCMToken != nil && pushNotificationGateOpen == true {
            if let uid = Auth.auth().currentUser?.uid {
                DataService.instance.updateDBUserFCMToken(uid: uid, token: deviceFCMToken!)
                //so it does not update everytime this view appears
                pushNotificationGateOpen = false
            }
        }
    }
    
    //MARK: SOCIAL LINKS
    
    @IBAction func facebookLink(_ sender: Any) {
        let fbPageID = user?.getFacebook()
        
        if let appURL = URL(string: "fb://profile/\(fbPageID!)") {
            let application = UIApplication.shared
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                // if Facebook app is not installed, open URL inside Safari
                let webURL = URL(string: "http://www.facebook.com/\(fbPageID!)")!
                if application.canOpenURL(webURL) {
                    application.open(webURL)
                //something went wrong with the URL
                } else {
                    displayError(title: "", message: "Couldn't open Facebook account")
                }
            }
        }
    }
    @IBAction func twitterLink(_ sender: Any) {
        //get the username
        let username =  user?.getTwitter()
        //make a url from username
        if let appURL = URL(string: "twitter://user?screen_name=\(username!)") {
            let application = UIApplication.shared
            //if app installed...
            if application.canOpenURL(appURL) {
                //...open in app
                application.open(appURL)
            } else {
                //if not installed, open in Safari browser
                let webURL = URL(string: "https://twitter.com/\(username!)")!
                if application.canOpenURL(webURL){
                    application.open(webURL)
                //URL doesn't work, display error
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
            } else {
                displayError(title: "", message: "Couldn't find website")
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
            } else {
                displayError(title: "", message: "Couldn't find Apple Music profile")
            }
        } else {
            displayError(title: "", message: "Couldn't find Apple Music profile")
        }
    }
    @IBAction func spotifyLink(_ sender: Any) {
        //get spotify string url
        let userStreaming = user?.getSpotify()
        //instantiate a url object
        if let webURL = URL(string: userStreaming!) {
            let application = UIApplication.shared
            //if can open in browser (or app)
            if application.canOpenURL(webURL) {
                application.open(webURL)
            //if can't open
            } else {
                displayError(title: "", message: "Couldn't find Spotify profile")
            }
        //if instantiation failed
        } else {
            displayError(title: "", message: "Couldn't find Spotify profile")
        }
    }
}
var deviceFCMToken: String?

