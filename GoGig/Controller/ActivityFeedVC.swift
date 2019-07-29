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
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshActivityFeed), name: NSNotification.Name(rawValue: "refreshActivityFeed"), object: nil)
        refreshActivityFeed()
        
        observeNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if feedGateOpen {
            feedGateOpen = false
            refreshActivityFeed()
        }
    }
    
    //MARK: FETCH DATA
    
    @objc func refreshActivityFeed() {
        if let uid = Auth.auth().currentUser?.uid {
            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                self.user = returnedUser
                DataService.instance.getDBActivityFeed(uid: uid) { (returnedActivityNotifications) in
                    self.activityNotifications = self.quickSort(array: returnedActivityNotifications)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: NOTIFICATION CELL
    
    func updateNotificationData(cell: ActivityFeedCell, row: Int) {
        
        cell.eventNameButton.setTitle(activityNotifications[row].getSenderName(), for: .normal)
        cell.notificationDescriptionLabel.text = activityNotifications[row].getNotificationDescription()
        
        loadImageCache(url: activityNotifications[row].getNotificationPicURL(), isImage: true) { (returnedImage) in
            cell.notificationImage.image = returnedImage
        }
    }
    
    //MARK: EVENT CELL
    
    
    //MARK: OBSERVE CHANGES
    
    func observeNotifications() {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference().child("users").child(uid!).child("activity")
        ref.observe(.childAdded, with: { (snapshot) in
            
            //Grab an array of all posts in the database
            if let activityData = snapshot.value as? NSDictionary {
                
                if let notificationID = activityData["notificationID"] as? String {
                    if let notificationType = activityData["type"] as? String {
                        if let senderUid = activityData["sender"] as? String {
                            if let recieverUid = activityData["reciever"] as? String {
                                if let senderName = activityData["senderName"] as? String {
                                    if let notificationPhotoURLStr = activityData["picURL"] as? String {
                                        if let notificationDescription = activityData["description"] as? String {
                                            if let timeInterval = activityData["timestamp"] as? TimeInterval {
                                                
                                                let notificationPhotoURL = URL(string: notificationPhotoURLStr)
                                                
                                                let notificationTime = NSDate(timeIntervalSince1970: timeInterval)
                                                
                                                let activityNotification = ActivityNotification(id: notificationID, type: notificationType, senderUid: senderUid, recieverUid: recieverUid, senderName: senderName, picURL: notificationPhotoURL!, description: notificationDescription, time: notificationTime)
                                                
                                                self.activityNotifications.insert(activityNotification, at: 0)
                                                self.collectionView.reloadData()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }, withCancel: nil)
    }
}
