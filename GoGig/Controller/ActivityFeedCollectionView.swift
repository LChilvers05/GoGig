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
        //Each collection view cell contains a table view
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cvCell", for: indexPath) as! ActivityCVCell
        //give each collection view cell a background
        setupView(tableview: cell.feedTableView)
        cell.feedTableView.reloadData()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //size of the collection view cells
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    //called before the UICollectionViewCell appears to the view
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let collectionViewCell = cell as? ActivityCVCell else { return }

        collectionViewCell.setTableViewDataSourceDelegate(dataSourceDelegate: self as UITableViewDataSource & UITableViewDelegate, forRow: indexPath.item)
        collectionViewCell.tableViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    //called after the UICollectionViewCell dissapears from the view
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let collectionViewCell = cell as? ActivityCVCell else { return }
        
        storedOffsets[indexPath.row] = collectionViewCell.tableViewOffset
    }
    
    //MARK: TABLEVIEW METHODS
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //Section 1 - Activity
        //Section 2 - Loading Cell
        if tableView.tag == 0 {
            return 2
        } else {
            //Don't need loading cell on the event listings
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 0 {
            //notifications section
            if section == 0 {
                //amound of cells needed
                return activityNotifications.count
                
            //loading more section
            } else {
                //if we are fetching more then return an extra cell (loading cell)
                return fetchingMore ? 1 : 0
            }
        } else {
            //event listing section
            return usersEvents.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! ActivityFeedCell
        //set nil while loading (cleaner)
        cell.notificationImage.image = nil
        //if notifications section
        if tableView.tag == 0 {
            //update notifications
            updateNotificationData(cell: cell, row: indexPath.row)
        //if 'My Events' section
        } else {
            //update the event listings
            updateEventListingData(cell: cell, row: indexPath.row)
            
        }
        //return the changes
        return cell
    }
    
    //when cell has been tapped (selected)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //activity notifications section
        if tableView.tag == 0 {
            let selectedNotification = activityNotifications[indexPath.row]
            //Making sure only an organsier can navigate to review application
            if user!.gigs == false && selectedNotification.getType() != "personal" && selectedNotification.getType() == "applied" {
                
                //So data is transfered when segue is performed
                checkUid = activityNotifications[indexPath.row].getSenderUid()
                selectedApplication = activityNotifications[indexPath.row]
                performSegue(withIdentifier: TO_REVIEW_APPLICATION, sender: nil)
            }
            
        //event listings section
        } else {
            selectedListing = usersEvents[indexPath.row]
            performSegue(withIdentifier: TO_EVENT_DESCRIPTION_2, sender: nil)
        }
    }
    
    //MARK: MENUBAR METHODS
    
    //change the purple bar position when scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Scrolled the collection view horizontally
        if scrollView == self.collectionView {
            menuBar.barLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 2
        
        //scrolled the table view vertically
        } else {
            
            //this is needed incase user has no data, causes a crash!
            if activityNotifications.count != 0 {
                
                let offsetY = scrollView.contentOffset.y
                let contentHeight = scrollView.contentSize.height
                if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {
                    
                    //if there is more activity to fetch
                    if !fetchingMore && !endReached {
                        getMoreNotifications()
                    }
                }
            }
        }
    }
    
    //change the state of menu bar when we finish dragging the large collection view cells
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == self.collectionView {
            let index = targetContentOffset.pointee.x / view.frame.width
            let indexPath = NSIndexPath(item: Int(index), section: 0)
            //go to the collection view cell at index
            menuBar.collectionView.selectItem(at: indexPath as IndexPath, animated: false, scrollPosition: .centeredHorizontally)
            //For selection of what button is pressed from what section
            selectedCVCell = Int(index)
        }
    }
    
    //called when the menu bar is used to change the cells
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = NSIndexPath(item: menuIndex, section: 0)
        //automatically scroll to that collection view cell
        collectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
        selectedCVCell = menuIndex
    }
}
