//
//  UserAccountTableView.swift
//  GoGig
//
//  Created by Lee Chilvers on 25/03/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import GoogleMaps
import GooglePlaces

//MARK: UserAccountVC TableView
extension UserAccountVC {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return portfolioPosts.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //FIRST CELL IS USER PROFILE
        if indexPath.row == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "AccountHeaderCell", for: indexPath) as! AccountHeaderCell
            
            updateUserData(cell: headerCell)
            
            return headerCell
            
            //OTHER CELLS ARE PORTFOLIO POSTS
            //need to create VC to put posts into storage
        } else {
            
            let postCell = tableView.dequeueReusableCell(withIdentifier: "AccountPostCell", for: indexPath)
                as! AccountPostCell
            
            
            updatePostData(cell: postCell, row: indexPath.row - 1)
            
            return postCell
            
        }
    }
    
    //To update the height of the row depending on the post
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 215
        } else {
            
            let ratio = (tableView.frame.size.width - 32) / ((portfolioPosts[indexPath.row-1].dimensions["width"] as? CGFloat)!)
            
            return ((portfolioPosts[indexPath.row-1].dimensions["height"] as? CGFloat)! * ratio) + 92
        }
    }
}

