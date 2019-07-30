//
//  RefreshSpinner.swift
//  GoGig
//
//  Created by Lee Chilvers on 03/05/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//


import UIKit

class LoadingCell: UITableViewCell {
    
    //Closure of the loading spinner
    let loadingSpinner: UIActivityIndicatorView = {
        let loadingSpinner = UIActivityIndicatorView(style: .white)
        loadingSpinner.translatesAutoresizingMaskIntoConstraints = false
        loadingSpinner.hidesWhenStopped = true
        return loadingSpinner
    }()
    
    override func awakeFromNib() {
        setupLoadingSpinner()
    }
    
    func setupLoadingSpinner() {
        
        addSubview(loadingSpinner)
        loadingSpinner.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        loadingSpinner.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        loadingSpinner.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        loadingSpinner.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
}
