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
    
    var refreshControl = UIRefreshControl()
    
    func getRefreshControl() -> UIRefreshControl {
        refreshControl.attributedTitle = NSAttributedString(string: "refreshing portfolio...")
        refreshControl.tintColor = UIColor.purple
        
        return refreshControl
    }
}
