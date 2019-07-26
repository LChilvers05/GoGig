//
//  ActivityFeedCollectionView.swift
//  GoGig
//
//  Created by Lee Chilvers on 23/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

extension ActivityFeedVC {
    
    //MARK: COLLECTION VIEW METHODS
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cvCell", for: indexPath) as! ActivityCVCell
        
        let colors: [UIColor] = [.red, .blue]
        
        cell.backgroundColor = colors[indexPath.item]
        
        return cell
    }
    
    //Called before the UICollectionViewCell appears to the view
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let collectionViewCell = cell as? ActivityCVCell else { return }

        collectionViewCell.setTableViewDataSourceDelegate(dataSourceDelegate: self as UITableViewDataSource & UITableViewDelegate, forRow: indexPath.item)
    }
    
    //MARK: TABLEVIEW METHODS
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! ActivityFeedCell

        cell.notificationDescriptionLabel.text = "Hello There From Lee"
        cell.eventNameButton.setTitle("Hello There", for: .normal)
        cell.notificationImage.image = UIImage(named: "findGigFilled")!

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped a cell")
    }
    
    //MARK: MENUBAR METHODS
    
    //Change the purple bar position when scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        menuBar.barLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 2
    }
    
    //Change the state of menu bar when we finish dragging the large collection view cells
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        let indexPath = NSIndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath as IndexPath, animated: false, scrollPosition: .centeredHorizontally)
        
    }
    
    //Called when the menu bar is used to change the cells
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = NSIndexPath(item: menuIndex, section: 0)
        collectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
    }
    
}
