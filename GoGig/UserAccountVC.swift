//
//  UserAccountVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 18/12/2018.
//  Copyright © 2018 ChillyDesigns. All rights reserved.
//

//  Profile Pic is distorted
//  User data does not load quickly

//  Constraints in table view cell

import UIKit
import AVFoundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class UserAccountVC: UITableViewController{
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = "Profile"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 350
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPortfolio), name: NSNotification.Name(rawValue: "refreshPortfolio"), object: nil)
        refreshPortfolio()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        refresh()
//    }
    
    //MARK: FETCH DATA
    var user: User?
    //We will reuse this VC when we want to look at someone else's profile
    //use did select row at to pass the user uid to this controller
    //if we didn't click on anything when the view appears, use the current user uid
    @objc func refreshPortfolio(){
        print("refreshed")
        if let uid = Auth.auth().currentUser?.uid { //^
            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                self.user = returnedUser
                self.loadImageCache(url: returnedUser.picURL, isImage: true) { (returnedProfileImage) in
                    self.profilePic = returnedProfileImage
                    DataService.instance.getDBPortfolioPosts(uid: uid) { (returnedPosts) in
                        self.portfolioPosts = self.quickSort(array:returnedPosts)
                        //print(self.portfolioPosts)
                        //self.portfolioPosts = returnedPosts
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func tempSignOut(_ sender: Any) {
        
        let logoutPopup = UIAlertController(title: "Logout?", message: "Are you sure you want to sign out of your account?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { (buttonTapped) in
            do {
                
                try Auth.auth().signOut()
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
                self.present(loginVC!, animated: true, completion: nil)
                
                //When the user logs out we need to return the tab bar to its original state ready for either type of user to log in
                if let tabBarController = self.tabBarController {
                    tabBarController.viewControllers = tabs
                    tabGateOpen = true
                    
                    DEFAULTS.set(nil, forKey: "gigs")
                }
                
            } catch {
                
                self.displayError(title: "There was an error", message: "Something went wrong, please try again")
            }
        }
        
        logoutPopup.addAction(logoutAction)
        present(logoutPopup, animated: true, completion: nil)
    }
    
    var portfolioPosts = [PortfolioPost]()
    
    //MARK: USER HEADER CELL
    var profilePic = UIImage(named: "icons8-user") //Have a placeholder image
    
    func updateUserData(cell: AccountHeaderCell){
        
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
        
        cell.postLocationLabel.text = portfolioPosts[row].location
        cell.postCaptionLabel.text = portfolioPosts[row].caption
        cell.postMoreButton.tag = row
        
        //show white space before the image can download, so we don't get flashing
        cell.postContainerView.addPhoto(imageContent: UIImage(named: "blankSpace")!)
        
        if portfolioPosts[row].isImage {
            
//            self.loadImageCache(url: portfolioPosts[row].postURL, isImage: portfolioPosts[row].isImage) { (returnedImage) in
//
//                cell.postContainerView.addPhoto(imageContent: returnedImage)
//
//            }
            
            cell.postContainerView.loadImageCacheToContainerView(url: portfolioPosts[row].postURL, isImage: portfolioPosts[row].isImage)
            
        } else {
            
//            self.loadImageCache(url: portfolioPosts[row].thumbnailURL, isImage: portfolioPosts[row].isImage) { (returnedImage) in
//
//                cell.postContainerView.addPhoto(imageContent: returnedImage)
//            }
            
            cell.postContainerView.loadImageCacheToContainerView(url: portfolioPosts[row].thumbnailURL, isImage: portfolioPosts[row].isImage)
        }
    }
    
    //To play a video when cell is tapped
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row != 0 { //so no crash when profile tapped
            
            let tappedCell = tableView.cellForRow(at: indexPath) as! AccountPostCell
            
            //If it's a video and tapped
            if !portfolioPosts[indexPath.row - 1].isImage {
                
                //Remove the thumbnail and play the video
                
                tappedCell.postContainerView.addVideo(url: portfolioPosts[indexPath.row - 1].postURL)
                
                tappedCell.postContainerView.playPlayer()
                
            }
        }
    }
    
    @IBAction func postMoreButton(_ sender: UIButton) {
        
        let row = sender.tag
        
        let morePopup = UIAlertController(title: "more", message: "", preferredStyle: .actionSheet)
        let deletePostAction = UIAlertAction(title: "Delete Post", style: .default) { (buttonTapped) in
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

