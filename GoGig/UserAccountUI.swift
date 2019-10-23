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
        emailField.attributedPlaceholder = NSAttributedString(string: "email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        passwordField.attributedPlaceholder = NSAttributedString(string: "password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: "confirm password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.3
            tv.layer.cornerRadius = 15
            //tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 40, height: fieldsStack.frame.height + topLSButton.frame.height + 75)
            //tv.center = CGPoint(x: self.view.bounds.width / 2, y: 300)
            tv.translatesAutoresizingMaskIntoConstraints = false
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
        
        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130),
            transparentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transparentView.widthAnchor.constraint(equalToConstant: fieldsStack.frame.width + 56),
            //transparentView.heightAnchor.constraint(equalToConstant: fieldsStack.frame.height + 112)
            transparentView.bottomAnchor.constraint(equalTo: topLSButton.bottomAnchor, constant: 16)
        ])
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension CreateProfileCAVC {
    func setupView() {
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.3
            tv.layer.cornerRadius = 15
//            if !editingProfile {
//                tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 40, height: nameBioStack.frame.height * 2)
//                tv.center = CGPoint(x: self.view.bounds.width / 2, y: nameBioStack.center.y - (nameBioStack.center.y / 4))
//            } else {
//                tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 50, height: nameBioStack.frame.height + 20)
//                tv.center = CGPoint(x: self.view.bounds.width / 2, y: nameBioStack.center.y)
            tv.translatesAutoresizingMaskIntoConstraints = false
//            }
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
        
        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            transparentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transparentView.widthAnchor.constraint(equalToConstant: nameBioStack.frame.width + 56),
            //transparentView.heightAnchor.constraint(equalToConstant: nameBioStack.frame.height + 112)
            transparentView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
        ])
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension SocialLinksCAVC {
    func setupView() {
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.3
            tv.layer.cornerRadius = 15
            //tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 40, height: fieldsStack.frame.height + 10)
            //tv.center = CGPoint(x: self.view.bounds.width / 2, y: fieldsStack.center.y)
            tv.translatesAutoresizingMaskIntoConstraints = false
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
        
        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            transparentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transparentView.widthAnchor.constraint(equalToConstant: fieldsStack.frame.width + 56),
            //transparentView.heightAnchor.constraint(equalToConstant: nameBioStack.frame.height + 112)
            transparentView.bottomAnchor.constraint(equalTo: fieldsStack.bottomAnchor, constant: 16)
        ])
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension MusicLinksCAVC {
    func setupView() {
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.3
            tv.layer.cornerRadius = 15
//            tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 40, height: fieldsStack.frame.height + 20)
//            tv.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
            tv.translatesAutoresizingMaskIntoConstraints = false
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
        
        NSLayoutConstraint.activate([
            transparentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transparentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            transparentView.widthAnchor.constraint(equalToConstant: fieldsStack.frame.width + 56),
            transparentView.heightAnchor.constraint(equalToConstant: fieldsStack.frame.height + 24)
        ])
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension TabBarController {
    func setupView(){
    }
}

extension UserAccountVC {
    func setupView() {
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.75)
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
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

extension PortfolioPostVC {
    func setupView() {
        navigationController?.navigationBar.barTintColor = UIColor.white.withAlphaComponent(0.90)
        let background = UIImage(named: "Background5")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.7
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension CreateGigVC {
    func setupView() {
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.4
            tv.layer.cornerRadius = 15
            tv.frame = CGRect.init(x: 0, y: 0, width: descriptionStack.frame.width + 20, height: descriptionStack.frame.height + 20)
            tv.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
            return tv
        }()
        
        //No back button
        
        let background = UIImage(named: "Background2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.7
        
        view.addSubview(transparentView)
        self.view.sendSubviewToBack(transparentView)
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension TitleDateCGVC {
    func setupView() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        self.navigationItem.hidesBackButton = true
        overrideUserInterfaceStyle = .light
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        let background = UIImage(named: "Background2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.4
        
        datePicker.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        datePicker.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        datePicker.layer.shadowRadius = 10.0
        datePicker.layer.shadowOpacity = 0.5
        datePicker.layer.cornerRadius = 10.0
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension LocationPriceCGVC {
    func setupView() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        overrideUserInterfaceStyle = .light
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        let background = UIImage(named: "Background2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.4
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension InfoContactCGVC {
    func setupView() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        overrideUserInterfaceStyle = .light
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        let background = UIImage(named: "Background2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.4
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension PhotoCGVC {
    func setupView() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        
        eventPicView.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        eventPicView.layer.shadowRadius = 10.0
        eventPicView.layer.shadowOpacity = 0.5
        eventPicView.layer.cornerRadius = 20.0
        
        let background = UIImage(named: "Background2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.4
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
}

extension ActivityFeedVC {
    func setupView(tableview: UITableView){
        let backgroundImage = UIImage(named: "Background3")
        let imageView = UIImageView(image: backgroundImage)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        tableview.backgroundView = imageView
        tableview.separatorStyle = .none
        
        imageView.alpha = 0.5
    }
}

extension FindGigVC {
    func setupView() {
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.4
            tv.layer.cornerRadius = 15
            //tv.frame = CGRect.init(x: 0, y: 0, width: contactStack.frame.width + 20, height: contactStack.frame.height + 20)
            tv.translatesAutoresizingMaskIntoConstraints = false
            return tv
        }()
        
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

        view.addSubview(transparentView)
        self.view.insertSubview(transparentView, at: 4)
        self.view.insertSubview(contactStack, at: 5)

        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            transparentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transparentView.widthAnchor.constraint(equalToConstant: contactStack.frame.width + 20),
            transparentView.heightAnchor.constraint(equalToConstant: contactStack.frame.height + 20)
        ])
    }
}

extension ReviewApplicationVC {
    func setupView() {
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.3
            tv.layer.cornerRadius = 15
            tv.translatesAutoresizingMaskIntoConstraints = false
            return tv
        }()
        
        let background = UIImage(named: "Background3")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.4
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
        
        view.addSubview(transparentView)
        self.view.sendSubviewToBack(transparentView)
        
        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 8),
            transparentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transparentView.widthAnchor.constraint(equalToConstant: nameLabel.frame.width - 16),
            transparentView.bottomAnchor.constraint(equalTo: eventLabel.bottomAnchor, constant: 8)
        ])
        
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
        
        profileImageView.layer.borderWidth = 0.1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
    }
}



extension EventDescriptionVC {
    func setupView() {
//        let transparentView: UIView = {
//            let tv = UIView()
//            tv.backgroundColor = #colorLiteral(red: 0.3918413535, green: 0.3957209708, blue: 0.3957209708, alpha: 1)
//            tv.alpha = 0.7
//            tv.layer.cornerRadius = 20
//            tv.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width - 50, height: self.view.frame.height - 200)
//            tv.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2 + 20)
//            return tv
//        }()
//
//        view.addSubview(transparentView)
//        self.view.sendSubviewToBack(transparentView)
        
        descriptionTextView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [UIColor(red: 255.0/255.0, green: 159.0/255.0, blue: 2.0/255.0, alpha: 0.5).cgColor, UIColor(red: 104.0/255.0, green: 35.0/255.0, blue: 128.0/255.0, alpha: 0.6).cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        gradient.cornerRadius = 10.0
        view.layer.insertSublayer(gradient, at: 0)
    }
}
