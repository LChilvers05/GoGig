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
        //Change the colour of the textfield placeholders so it can be seen on background
        emailField.attributedPlaceholder = NSAttributedString(string: "email",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        passwordField.attributedPlaceholder = NSAttributedString(string: "password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: "confirm password",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3])
        //Closure to instantiate transparent uiview object
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            //Transparent
            tv.alpha = 0.3
            //Rounded corners
            tv.layer.cornerRadius = 15
            //can be autoresized by programmatic constaints
            tv.translatesAutoresizingMaskIntoConstraints = false
            return tv
        }()
        //Set up a background image and stretch it to all edges of the screens
        let background = UIImage(named: "Background")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        //scale the image so it fills the image view
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        //image view is in the center of the view and clip it to the edges of screen
        imageView.center = view.center
        
        //Add the transparent view to view
        view.addSubview(transparentView)
        //send it to the back of all UI elements
        self.view.sendSubviewToBack(transparentView)
        
        //Set transparent view constraints so it sits behind the fields stack with right dimensions
        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130),
            transparentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transparentView.widthAnchor.constraint(equalToConstant: fieldsStack.frame.width + 56),
            transparentView.bottomAnchor.constraint(equalTo: topLSButton.bottomAnchor, constant: 16)
        ])
        //add the background to view
        view.addSubview(imageView)
        //send it to the back of all the subviews
        self.view.sendSubviewToBack(imageView)
    }
}

extension CreateProfileCAVC {
    func setupView() {
        //Closure to instantiate transparent uiview object
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.3
            tv.layer.cornerRadius = 15
            tv.translatesAutoresizingMaskIntoConstraints = false
            return tv
        }()
        //Set up a background image and stretch it to all edges of the screens
        let background = UIImage(named: "Background")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        //Add the transparent view to view
        view.addSubview(transparentView)
        //send it to the back of all UI elements
        self.view.sendSubviewToBack(transparentView)
        //Set transparent view constraints so it sits behind the fields stack with right dimensions
        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 64),
            transparentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transparentView.widthAnchor.constraint(equalToConstant: nameBioStack.frame.width + 56),
            transparentView.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
        ])
        //add the background to view
        view.addSubview(imageView)
        //send it to the back of all the subviews
        self.view.sendSubviewToBack(imageView)
    }
}

extension SocialLinksCAVC {
    func setupView() {
        //Closure to instantiate transparent uiview object
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.3
            tv.layer.cornerRadius = 15
            tv.translatesAutoresizingMaskIntoConstraints = false
            return tv
        }()
        //Set up a background image and stretch it to all edges of the screens
        let background = UIImage(named: "Background")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        //Add the transparent view to view
        view.addSubview(transparentView)
        //send it to the back of all UI elements
        self.view.sendSubviewToBack(transparentView)
        //Set transparent view constraints so it sits behind with right dimensions
        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48),
            transparentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transparentView.widthAnchor.constraint(equalToConstant: fieldsStack.frame.width + 56),
            transparentView.bottomAnchor.constraint(equalTo: fieldsStack.bottomAnchor, constant: 16)
        ])
        //add the background to view
        view.addSubview(imageView)
        //send it to the back of all the subviews
        self.view.sendSubviewToBack(imageView)
    }
}

extension MusicLinksCAVC {
    func setupView() {
        //Closure to instantiate transparent uiview object
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.3
            tv.layer.cornerRadius = 15
            tv.translatesAutoresizingMaskIntoConstraints = false
            return tv
        }()
        //Set up a background image and stretch it to all edges of the screens
        let background = UIImage(named: "Background")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        //Add the transparent view to view
        view.addSubview(transparentView)
        //send it to the back of all UI elements
        self.view.sendSubviewToBack(transparentView)
        //Set transparent view constraints so it sits behind with right dimensions
        NSLayoutConstraint.activate([
            transparentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transparentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            transparentView.widthAnchor.constraint(equalToConstant: fieldsStack.frame.width + 56),
            transparentView.heightAnchor.constraint(equalToConstant: fieldsStack.frame.height + 24)
        ])
        //add the background to view
        view.addSubview(imageView)
        //send it to the back of all the subviews
        self.view.sendSubviewToBack(imageView)
    }
}

extension UserAccountVC {
    func setupView() {
        //use a large title as the name at top of portfolio
        self.navigationController?.navigationBar.prefersLargeTitles = true
        //if iOS 13
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            //set the navigation bar as opaque...
            navBarAppearance.configureWithOpaqueBackground()
            //...with a white colour
            navBarAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.75)
            //set this appearance when table view is still and scrolling
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        //background image will be the background of the table view
        let backgroundImage = UIImage(named: "Background")
        let imageView = UIImageView(image: backgroundImage)
        self.tableView.backgroundView = imageView
        self.tableView.separatorStyle = .none
        imageView.contentMode = .scaleAspectFit
        
        //provide a blur effect over the feed background, light style
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        //add the image as background to table view
        imageView.addSubview(blurView)
        //automatically resize the cells depending on its content dimensions
        tableView.rowHeight = UITableView.automaticDimension
        //if fails (or loading) provide estimate height
        tableView.estimatedRowHeight = 350
    }
}

extension PortfolioPostVC {
    func setupView() {
        //make the navigation bar white with set opacity and white colour
        navigationController?.navigationBar.barTintColor = UIColor.white.withAlphaComponent(0.90)
        //Set up a background image and stretch it to all edges of the screens
        let background = UIImage(named: "Background5")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.7
        //set background image and pin to edges of view
        view.addSubview(imageView)
        //send it behind all UI elements
        self.view.sendSubviewToBack(imageView)
    }
}

extension CreateGigVC {
    func setupView() {
        //Closure to instantiate transparent uiview object
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.4
            tv.layer.cornerRadius = 15
            //use frame for dimensions rather than constraints
            tv.frame = CGRect.init(x: 0, y: 0, width: descriptionStack.frame.width + 20, height: descriptionStack.frame.height + 20)
            tv.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
            return tv
        }()
        
        //Set up a background image and stretch it to all edges of the screens
        let background = UIImage(named: "Background2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.7
        //Add the transparent view to view
        view.addSubview(transparentView)
        //send it to the back of all UI elements
        self.view.sendSubviewToBack(transparentView)
        //add the background to view
        view.addSubview(imageView)
        //send it to the back of all the subviews
        self.view.sendSubviewToBack(imageView)
    }
}

extension TitleDateCGVC {
    func setupView() {
        //large title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        //if iOS 13
        if #available(iOS 13.0, *) {
            //set the navigation bar with the large title as basically clear
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        }
        //hide the default back button
        self.navigationItem.hidesBackButton = true
        //make our own back button
        let backItem = UIBarButtonItem()
        backItem.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        
        //set background
        let background = UIImage(named: "Background2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.4
        
        //set opacity of datepicker
        datePicker.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        //give it a shadow
        datePicker.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        //set size and strength and shape of shadow
        datePicker.layer.shadowRadius = 10.0
        datePicker.layer.shadowOpacity = 0.5
        datePicker.layer.cornerRadius = 10.0
        //add the background to view
        view.addSubview(imageView)
        //send it to the back of all the subviews
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
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
        //Set up a background image and stretch it to all edges of the screens
        let background = UIImage(named: "Background2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.4
        //add the background to view
        view.addSubview(imageView)
        //send it to the back of all the subviews
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
        //Set up a background image and stretch it to all edges of the screens
        let background = UIImage(named: "Background2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.4
        //add the background to view
        view.addSubview(imageView)
        //send it to the back of all the subviews
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
        //give the eventPicView a shadow and set its size, shape and strength
        eventPicView.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        eventPicView.layer.shadowRadius = 10.0
        eventPicView.layer.shadowOpacity = 0.5
        eventPicView.layer.cornerRadius = 20.0
        //Set up a background image and stretch it to all edges of the screens
        let background = UIImage(named: "Background2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.4
        //add the background to view
        view.addSubview(imageView)
        //send it to the back of all the subviews
        self.view.sendSubviewToBack(imageView)
    }
}

extension ActivityFeedVC {
    func setupView(tableview: UITableView){
        let backgroundImage = UIImage(named: "Background3")
        let imageView = UIImageView(image: backgroundImage)
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        //tableview.backgroundView = imageView
        tableview.separatorStyle = .none
        imageView.alpha = 0.5
    }
}

extension FindGigVC {
    func setupView() {
        //Closure to instantiate transparent uiview object
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.4
            tv.layer.cornerRadius = 15
            tv.translatesAutoresizingMaskIntoConstraints = false
            return tv
        }()
        //Set up a background image and stretch it to all edges of the screens
        let background = UIImage(named: "Background2")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.5
        //add the background to view
        view.addSubview(imageView)
        //send it to the back of all the subviews
        self.view.sendSubviewToBack(imageView)
        
        //add the transparent view
        view.addSubview(transparentView)
        //set it at z index 4
        self.view.insertSubview(transparentView, at: 4)
        //ensure the contact details are z index 5 (sits ontop)
        self.view.insertSubview(contactStack, at: 5)
        //Set transparent view constraints so it sits behind with right dimensions
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
        //Closure to instantiate transparent uiview object
        let transparentView: UIView = {
            let tv = UIView()
            tv.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tv.alpha = 0.3
            tv.layer.cornerRadius = 15
            tv.translatesAutoresizingMaskIntoConstraints = false
            return tv
        }()
        //Set up a background image and stretch it to all edges of the screens
        let background = UIImage(named: "Background3")
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        imageView.alpha = 0.4
        //give the background a blur effect
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = imageView.bounds
        imageView.addSubview(blurView)
        //Add the transparent view to view
        view.addSubview(transparentView)
        //send it to the back of all UI elements
        self.view.sendSubviewToBack(transparentView)
        //Set transparent view constraints so it sits behind with right dimensions
        NSLayoutConstraint.activate([
            transparentView.topAnchor.constraint(equalTo: nameLabel.topAnchor, constant: 8),
            transparentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            transparentView.widthAnchor.constraint(equalToConstant: nameLabel.frame.width - 16),
            transparentView.bottomAnchor.constraint(equalTo: eventLabel.bottomAnchor, constant: 8)
        ])
        //add the background to view
        view.addSubview(imageView)
        //send it to the back of all the subviews
        self.view.sendSubviewToBack(imageView)
        //make the profile image view a circle and not a square
        profileImageView.layer.borderWidth = 0.1
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
    }
}



extension EventDescriptionVC {
    func setupView() {
        //make the background of text view white but see-through
        descriptionTextView.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        //create a gradient (rather than image) to use as background
        let gradient: CAGradientLayer = CAGradientLayer()
        //two stops, orange to purple
        gradient.colors = [UIColor(red: 255.0/255.0, green: 159.0/255.0, blue: 2.0/255.0, alpha: 0.5).cgColor, UIColor(red: 104.0/255.0, green: 35.0/255.0, blue: 128.0/255.0, alpha: 0.6).cgColor]
        //from top to bottom
        gradient.locations = [0.0 , 1.0]
        //full screen
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.bounds.size.width, height: self.view.bounds.size.height)
        gradient.cornerRadius = 10.0
        view.layer.insertSublayer(gradient, at: 0)
    }
}
