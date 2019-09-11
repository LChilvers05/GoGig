//
//  ActivityFeedCell.swift
//  GoGig
//
//  Created by Lee Chilvers on 22/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class ActivityFeedCell: UITableViewCell {
    
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var eventNameButton: UIButton!
    @IBOutlet weak var notificationDescriptionLabel: UILabel!
    @IBOutlet weak var deleteNotificationButton: UIButton!
    
    override func awakeFromNib() {
        
        notificationImage.layer.borderWidth = 0.1
        notificationImage.layer.masksToBounds = false
        notificationImage.layer.cornerRadius = notificationImage.frame.height/2
        notificationImage.clipsToBounds = true
        self.backgroundColor = UIColor(white: 1, alpha: 0.75)
    }
    
}
