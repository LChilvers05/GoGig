//
//  UserAccountUI.swift
//  GoGig
//
//  Created by Lee Chilvers on 16/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

extension LoginSignupVC {
    func setupView() {
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.2
            tv.layer.cornerRadius = 15
            tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 40, height: fieldsStack.frame.height + topLSButton.frame.height + 75)
            tv.center = CGPoint(x: self.view.bounds.width / 2, y: fieldsStack.center.y + (topLSButton.frame.height * 1.2))
            return tv
        }()
        let background = UIImage(named: "Background")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        
        view.addSubview(transparentView)
        self.view.sendSubviewToBack(transparentView)
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension CreateProfileCAVC {
    func setupView() {
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.2
            tv.layer.cornerRadius = 15
            if !editingProfile {
                tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 40, height: nameBioStack.frame.height * 2)
                tv.center = CGPoint(x: self.view.bounds.width / 2, y: nameBioStack.center.y - (nameBioStack.center.y / 4))
            } else {
                tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 50, height: nameBioStack.frame.height + 20)
                tv.center = CGPoint(x: self.view.bounds.width / 2, y: nameBioStack.center.y)
            }
            return tv
        }()
        let background = UIImage(named: "Background")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        
        view.addSubview(transparentView)
        self.view.sendSubviewToBack(transparentView)
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension SocialLinksCAVC {
    func setupView() {
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.2
            tv.layer.cornerRadius = 15
            tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 40, height: fieldsStack.frame.height + 10)
            tv.center = CGPoint(x: self.view.bounds.width / 2, y: fieldsStack.center.y)
            return tv
        }()
        let background = UIImage(named: "Background")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        
        view.addSubview(transparentView)
        self.view.sendSubviewToBack(transparentView)
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension MusicLinksCAVC {
    func setupView() {
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.2
            tv.layer.cornerRadius = 15
            tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 40, height: fieldsStack.frame.height + 20)
            tv.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            return tv
        }()
        let background = UIImage(named: "Background")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        
        view.addSubview(transparentView)
        self.view.sendSubviewToBack(transparentView)
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

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

extension EventDescriptionVC {
    func setupView() {
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0.3918413535, green: 0.3957209708, blue: 0.3957209708, alpha: 1)
            tv.alpha = 0.7
            tv.layer.cornerRadius = 20
            tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 50, height: self.view.frame.height - 200)
            tv.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2 + 20)
            return tv
        }()
        let background = UIImage(named: "Background4")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.5
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        view.addSubview(transparentView)
        self.view.sendSubviewToBack(transparentView)
    }
}
