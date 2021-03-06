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
    @IBOutlet weak var userBioTextView: MyTextView!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userPhoneLabel: UILabel!
    @IBOutlet weak var facebookLinkButton: UIButton!
    @IBOutlet weak var twitterLinkButton: UIButton!
    @IBOutlet weak var instagramLinkButton: UIButton!
    @IBOutlet weak var websiteLinkButton: UIButton!
    @IBOutlet weak var appleMusicLinkButton: UIButton!
    @IBOutlet weak var spotifyLinkButton: UIButton!
    @IBOutlet weak var socialLinkStackView: UIStackView!
    
    override func awakeFromNib() {
        //Give the profile image a small border and make it round
        profilePicView.layer.borderWidth = 0.1
        profilePicView.layer.masksToBounds = false
        profilePicView.layer.cornerRadius = profilePicView.frame.height/2
        profilePicView.clipsToBounds = true
        //Set cell to be an opaque white colour
        self.backgroundColor = UIColor(white: 1, alpha: 0.75)
    }
}

