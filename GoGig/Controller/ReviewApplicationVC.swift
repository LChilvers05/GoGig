//
//  ReviewApplicationVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 31/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class ReviewApplicationVC: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var nameButton: UIButton!
    
    var user: User?
    var uid: String?
    var gigEvent: GigEvent?
    
    func refresh() {
        
        DataService.instance.getDBUserProfile(uid: uid!) { (returnedUser) in
            self.user = returnedUser
            self.nameLabel.text = returnedUser.name
            self.nameButton.setTitle("Check out \(returnedUser.name)", for: .normal)
            self.loadImageCache(url: returnedUser.picURL, isImage: true) { (returnedProfileImage) in
                self.profileImageView.image = returnedProfileImage
            }
        }
    }
    

    @IBAction func checkUid(_ sender: Any) {
        
    }
    
    @IBAction func rejectUser(_ sender: Any) {
    }
    @IBAction func acceptUser(_ sender: Any) {
    }
    
}
