//
//  UserAccountUI.swift
//  GoGig
//
//  Created by Lee Chilvers on 16/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

extension UserAccountVC {
    
    func setupView() {
        let backgroundImage = UIImage(named: "Background")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        imageView.contentMode = .scaleAspectFit
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        //self.navigationController?.navigationBar.topItem?.title = "Profile"
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 350
    }
}
