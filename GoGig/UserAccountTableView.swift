//
//  UserAccountTableView.swift
//  GoGig
//
//  Created by Lee Chilvers on 25/03/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import GoogleMaps
import GooglePlaces

//MARK: UserAccountVC TableView
extension UserAccountVC {
    
    //Now each row of the table view is a section to allow padding
    override func numberOfSections(in tableView: UITableView) -> Int {
        //+1 is AccountHeaderCell
        return portfolioPosts.count + 1
    }
    
    //In each section is one row
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //set the appearance of each cell
    //We access the row using indexPath.section instead of indexPath.row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //FIRST CELL IS USER PROFILE
        if indexPath.section == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "AccountHeaderCell", for: indexPath) as! AccountHeaderCell
            
            //On initial launch of the app, clean the header
            if hideForLoad {
                headerCell.userBioTextView.isHidden = true
                headerCell.userTypeLabel.isHidden = true
                headerCell.socialLinkStackView.isHidden = true
            } else {
                headerCell.userBioTextView.isHidden = false
                headerCell.userTypeLabel.isHidden = false
                headerCell.socialLinkStackView.isHidden = false
            }
            //update the cell with the user data
            updateUserData(cell: headerCell)
            
            return headerCell
            
        //OTHER CELLS ARE PORTFOLIO POSTS
        } else {
            //instantiate a reusable post cell
            let postCell = tableView.dequeueReusableCell(withIdentifier: "AccountPostCell", for: indexPath)
                as! AccountPostCell
            
            //add post data to the cell
            updatePostData(cell: postCell, row: indexPath.section - 1)
            
            return postCell
            
        }
    }
    
    //To update the height of the row depending on the post
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Account Header is always same height
        if indexPath.section == 0 {
            return 215
        } else {
            //this is the ratio of feed with to post width
            let ratio = (tableView.frame.size.width - 32) / ((portfolioPosts[indexPath.section-1].dimensions["width"] as? CGFloat)!)
            //set the height of the cell based off ratio
            return ((portfolioPosts[indexPath.section-1].dimensions["height"] as? CGFloat)! * ratio) + 92
        }
    }
    
    
    //Add padding to the cells
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 20
        }
        //No top padding for top cell
        return 0
    }
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    //when scrolling the feed
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if #available(iOS 13.0, *) {
            //give the navigation bar an opaque white colour
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.95)
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
    //when stopped scrolling feed
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if #available(iOS 13.0, *) {
            //give the navigation bar an opaque white colour
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.75)
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
    }
}

