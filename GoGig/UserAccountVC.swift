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
    
    var user: User?
    var uid: String?
    var portfolioPosts = [PortfolioPost]()
    
    override func viewDidLoad() {
        
        setupView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPortfolio), name: NSNotification.Name(rawValue: "refreshPortfolio"), object: nil)
        refreshPortfolio()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        refresh()
//    }
    
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
                
                //So does not update account which is not theirs
                if let uid = Auth.auth().currentUser?.uid {
                    DataService.instance.removeObservers(uid: uid)
                }
                
                try Auth.auth().signOut()
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
                self.present(loginVC!, animated: true, completion: nil)
                
                //When the user logs out we need to return the tab bar to its original state ready for either type of user to log in
                if let tabBarController = self.tabBarController {
                    tabBarController.viewControllers = tabs
                    tabGateOpen = true
                    accountGateOpen = true
                    cardGateOpen = true
                    feedGateOpen = true
                    observeGateOpen = true
                
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
            cell.addToPortfolioButton.isHidden = true
            cell.signOutButton.isHidden = true
        }
        
        //Set the navigation bar title
        self.navigationController?.navigationBar.topItem?.title = user?.name
        
        //Set UI
        cell.bioLabel.text = user?.bio
        if user?.gigs == true {
            cell.userTypeLabel.text = "Looking to play"
        } else {
            cell.userTypeLabel.text = "Hiring"
        }
        
        cell.profilePicView.image = profilePic
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
}

