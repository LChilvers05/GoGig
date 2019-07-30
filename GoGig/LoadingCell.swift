//
//  RefreshSpinner.swift
//  GoGig
//
//  Created by Lee Chilvers on 03/05/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//


import UIKit

class LoadingCell: UITableViewCell {
    
    //Closure of the refresh spinner
    let refreshSpinner: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "refreshing....")
        refreshControl.tintColor = UIColor.purple
        
        return refreshControl
    }()
    
    override func awakeFromNib() {
        <#code#>
    }
}
