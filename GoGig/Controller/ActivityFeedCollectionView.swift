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
        //Each cv cell contains a table view
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cvCell", for: indexPath) as! ActivityCVCell
        
        //MAY NOT NEED THIS
        setupView(tableview: cell.feedTableView)
        cell.feedTableView.reloadData()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    //Called before the UICollectionViewCell appears to the view
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let collectionViewCell = cell as? ActivityCVCell else { return }

        collectionViewCell.setTableViewDataSourceDelegate(dataSourceDelegate: self as UITableViewDataSource & UITableViewDelegate, forRow: indexPath.item)
        collectionViewCell.tableViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    //Called after the UICollectionViewCell dissapears from the view
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
        
        cell.notificationImage.image = nil
        
        if tableView.tag == 0 {
            
            updateNotificationData(cell: cell, row: indexPath.row)
            
        } else {
            
            updateEventListingData(cell: cell, row: indexPath.row)
            
//            cell.notificationDescriptionLabel.text = "Hello There From Lee"
//            cell.eventNameButton.setTitle("Hello There", for: .normal)
//            cell.notificationImage.image = UIImage(named: "findGigFilled")!
            
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //activity notifications section
        if tableView.tag == 0 {
            let selectedNotification = activityNotifications[indexPath.row]
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
    
    //Change the purple bar position when scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //Scrolled the collection view horizontally
        if scrollView == self.collectionView {
            menuBar.barLeftAnchorConstraint?.constant = scrollView.contentOffset.x / 2
        
        //Scrolled the table view vertically
        } else {
            
            //This is needed incase user has no data, causes a crash!
            if activityNotifications.count != 0 {
                
                let offsetY = scrollView.contentOffset.y
                let contentHeight = scrollView.contentSize.height
                if offsetY > contentHeight - scrollView.frame.size.height * leadingScreensForBatching {
                    
                    //If there is more activity to fetch
                    if !fetchingMore && !endReached {
                        getMoreNotifications()
                    }
                }
            }
        }
    }
    
    //Change the state of menu bar when we finish dragging the large collection view cells
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == self.collectionView {
            let index = targetContentOffset.pointee.x / view.frame.width
            let indexPath = NSIndexPath(item: Int(index), section: 0)
            menuBar.collectionView.selectItem(at: indexPath as IndexPath, animated: false, scrollPosition: .centeredHorizontally)
            //For selection of what button is pressed from what section
            selectedCVCell = Int(index)
        }
    }
    
    //Called when the menu bar is used to change the cells
    func scrollToMenuIndex(menuIndex: Int) {
        let indexPath = NSIndexPath(item: menuIndex, section: 0)
        collectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
        selectedCVCell = menuIndex
    }
}
