//
//  AccountHeaderCell.swift
//
//
//  Created by Lee Chilvers on 21/12/2018.
//

import UIKit
import FirebaseAuth

class AccountHeaderCell: UITableViewCell {
    
    @IBOutlet weak var userTypeLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var addToPortfolioButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    override func awakeFromNib() {
        
        profilePicView.layer.borderWidth = 0.1
        profilePicView.layer.masksToBounds = false
        profilePicView.layer.cornerRadius = profilePicView.frame.height/2
        profilePicView.clipsToBounds = true
        self.backgroundColor = UIColor(white: 1, alpha: 0.75)
    }
}

