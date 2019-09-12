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
        self.tableView.separatorStyle = .none
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

extension ActivityFeedVC {
    
    func setupView(tableview: UITableView){
        let backgroundImage = UIImage(named: "Background3")
        let imageView = UIImageView(image: backgroundImage)
        tableview.backgroundView = imageView
        tableview.separatorStyle = .none
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.5
        
    }
    
}

extension FindGigVC {
    
    func setupView() {
        let background = UIImage(named: "Background2")
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.5
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension ReviewApplicationVC {
    
    func setupView() {
        
        let backgroundImage = UIImage(named: "Background")
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFit
        view.sendSubviewToBack(imageView)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
        
        profileImageView.layer.borderWidth = 0.1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        
    }
}

extension PhotoCGVC {
    
    func setupView() {
        eventPicView.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        eventPicView.layer.shadowRadius = 10.0
        eventPicView.layer.shadowOpacity = 0.5
        eventPicView.layer.cornerRadius = 20.0
    }
}
