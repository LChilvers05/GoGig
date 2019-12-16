//
//  SpinnerViewController.swift
//  GoGig
//
//  Created by Lee Chilvers on 02/10/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class SpinnerViewController: UIViewController {
    
    var spinner = UIActivityIndicatorView(style: .whiteLarge)

    override func loadView() {
        //create a which is black with 0.5 opacity
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        //start and add spinner
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        //center the spinner
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
