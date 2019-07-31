//
//  ActivityFeedVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 22/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

//Can't get table view to connect to the collection view delgate data source?

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ActivityFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var storedOffsets = [Int: CGFloat]()
    
    //Instantiation of menubar in a closure
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.activityFeedVC = self
        return mb
    }()
    
    private func setupMenuBar() {
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        
        view.addSubview(menuBar)
        menuBar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        menuBar.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        menuBar.bottomAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        menuBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    var user: User?
    var activityNotifications = [ActivityNotification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuBar()
        feedGateOpen = false
        refreshActivityFeed()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.topItem?.title = "Activity"
    }
    override func viewDidAppear(_ animated: Bool) {
        if feedGateOpen {
            //Need to remove all on sign in otherwise it doesn't refresh
            //what has been 'observed' since view did load
            activityNotifications.removeAll()
            feedGateOpen = false
            refreshActivityFeed()
        }
    }
    
    //MARK: FETCH DATA
    var observeGate = true
    func refreshActivityFeed() {
        if let uid = Auth.auth().currentUser?.uid {
            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                self.user = returnedUser
                
                self.fetchingMore = true
                DataService.instance.getDBActivityFeed(uid: uid, currentActivity: self.activityNotifications) { (returnedActivityNotifications) in
                    self.activityNotifications = returnedActivityNotifications
                    
                    self.endReached = (returnedActivityNotifications.count == 0)
                    self.fetchingMore = false
                    
                    self.collectionView.reloadData()
                }
            }
        }
        
        //We have done initial refresh, now observe any additions
        //Need gate to refresh properly on sign out and in
        if observeGate {
            observeGate = false
            observeNotifications()
        }
    }
    
    //MARK: NOTIFICATION CELL
    
    func updateNotificationData(cell: ActivityFeedCell, row: Int) {
        
        cell.eventNameButton.setTitle(activityNotifications[row].getSenderName(), for: .normal)
        cell.eventNameButton.tag = row
        cell.notificationDescriptionLabel.text = activityNotifications[row].getNotificationDescription()
        
        loadImageCache(url: activityNotifications[row].getNotificationPicURL(), isImage: true) { (returnedImage) in
            cell.notificationImage.image = returnedImage
        }
    }
    
    //MARK: NOTIFICATION CELL ACTIONS
    var checkUid: String?
    @IBAction func checkOut(_ sender: UIButton) {
        
        let row = sender.tag
        
        checkUid = activityNotifications[row].getSenderUid()
        
        performSegue(withIdentifier: TO_CHECK_PORTFOLIO, sender: nil)
    }
    
    //MARK: EVENT CELL
    
    //MARK: FETCH MORE DATA
    //(Pagination)
    
    var fetchingMore = false
    //If reached the end, don't bother fetching anymore posts
    var endReached = false
    //Start loading notifications 3 cells in advance
    var leadingScreensForBatching: CGFloat = 3.0
    
    func getMoreNotifications(){
        fetchingMore = true
        
        print(self.activityNotifications.count)
        
        DataService.instance.getDBActivityFeed(uid: user!.uid, currentActivity: activityNotifications) { (returnedActivityNotifications) in
            //We are appending the contents of the array, not the array itself
            self.activityNotifications.append(contentsOf: returnedActivityNotifications)
            
            //If no more notifications, we have reached the end
            self.endReached = (returnedActivityNotifications.count == 0)
            self.fetchingMore = false
            self.collectionView.reloadData()
            
            print(self.activityNotifications.count)
        }
    }
    
    //MARK: OBSERVE CHANGES
    
    func observeNotifications(){
        
        if let uid = Auth.auth().currentUser?.uid {
            DataService.instance.observeDBActivityFeed(uid: uid) { (returnedActivityNotification) in
                if self.activityNotifications.contains(returnedActivityNotification) == false {
                    self.activityNotifications.insert(returnedActivityNotification, at: 0)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_CHECK_PORTFOLIO {
            
            let userAccountVC = segue.destination as! UserAccountVC
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            userAccountVC.uid = checkUid!
            userAccountVC.refreshPortfolio()
            
        } else if segue.identifier == TO_REVIEW_APPLICATION {
            
            let reviewApplicationVC = segue.destination as! ReviewApplicationVC
            
            reviewApplicationVC.uid = checkUid!
            reviewApplicationVC.refresh()
        }
    }
}
