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
        
        //Tag allows us to distinguish between the table views within the cv cells for datasource
        feedTableView.tag = row
        feedTableView.reloadData()
        feedTableView.addSubview(refreshControl)
        
        //Tab to scroll to top
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToTop), name: NSNotification.Name(rawValue: "scrollToTop"), object: nil)
    }
    
    //Pull to refresh
    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        rc.tintColor = UIColor.purple
        return rc
    }()
    
    @objc func pullToRefresh() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshAllActivity"), object: nil)
        refreshControl.endRefreshing()
    }
    
    @objc func scrollToTop() {
        feedTableView.setContentOffset(.zero, animated: true)
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
