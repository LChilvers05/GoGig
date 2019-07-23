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
        return portfolioPosts.count + 1
    }
    
    //In each section is one row
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //We access the row using indexPath.section instead of indexPath.row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //FIRST CELL IS USER PROFILE
        if indexPath.section == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "AccountHeaderCell", for: indexPath) as! AccountHeaderCell
            
            updateUserData(cell: headerCell)
            
            return headerCell
            
            //OTHER CELLS ARE PORTFOLIO POSTS
            //need to create VC to put posts into storage
        } else {
            
            let postCell = tableView.dequeueReusableCell(withIdentifier: "AccountPostCell", for: indexPath)
                as! AccountPostCell
            
            
            updatePostData(cell: postCell, row: indexPath.section - 1)
            
            return postCell
            
        }
    }
    
    //To update the height of the row depending on the post
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 215
        } else {
            
            let ratio = (tableView.frame.size.width - 32) / ((portfolioPosts[indexPath.section-1].dimensions["width"] as? CGFloat)!)
            
            return ((portfolioPosts[indexPath.section-1].dimensions["height"] as? CGFloat)! * ratio) + 92
        }
    }
    
    
    //Add padding to the cells
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section != 0 {
            return 20
        }
        return 0
    }
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

