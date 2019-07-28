//
//  ActivityCollectionViewCell.swift
//  GoGig
//
//  Created by Lee Chilvers on 25/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class ActivityCVCell: UICollectionViewCell {
    
    @IBOutlet weak var feedTableView: UITableView!
    
    //Link the table view datasource and delegate to the view controller rather than the collection view cell with a tag
    //So that we can stick by the model-view-controller, rather than working from the ActivityCVCell class
    func setTableViewDataSourceDelegate(dataSourceDelegate: UITableViewDataSource & UITableViewDelegate, forRow row: Int) {
        feedTableView.delegate = dataSourceDelegate
        feedTableView.dataSource = dataSourceDelegate
        
        //Tag allows us to distinguish between the table views within the  cv cells for datasource
        feedTableView.tag = row
        feedTableView.reloadData()
    }
    
    
    var tableViewOffset: CGFloat {
        get {
            return feedTableView.contentOffset.x
        }
        
        set {
            feedTableView.contentOffset.x = newValue
        }
    }
}
