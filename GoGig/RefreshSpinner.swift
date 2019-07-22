//
//  RefreshSpinner.swift
//  GoGig
//
//  Created by Lee Chilvers on 03/05/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation
import UIKit

class RefreshSpinner {
    
    //Closure of the refresh spinner
    let refreshSpinner: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "refreshing....")
        refreshControl.tintColor = UIColor.purple
        
        return refreshControl
    }()
}
