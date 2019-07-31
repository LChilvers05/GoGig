//
//  ReviewApplicationUI.swift
//  GoGig
//
//  Created by Lee Chilvers on 31/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

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
