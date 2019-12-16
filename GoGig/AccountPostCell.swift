//
//  AccountPostCell.swift
//  GoGig
//
//  Created by Lee Chilvers on 21/12/2018.
//  Copyright © 2018 ChillyDesigns. All rights reserved.
//

import UIKit

class AccountPostCell: UITableViewCell {
    
    @IBOutlet weak var postLocationLabel: UILabel!
    @IBOutlet weak var postCaptionTextView: MyTextView!
    @IBOutlet weak var postContainerView: PostContainerView!
    @IBOutlet weak var postMoreButton: UIButton!
    
    override func awakeFromNib() {
        //so user cannot edit the caption text view
        postCaptionTextView.isEditable = false
        //slightly more opaque than the AccountHeaderCell
        self.backgroundColor = UIColor(white: 1, alpha: 0.5)
    }
    
}
