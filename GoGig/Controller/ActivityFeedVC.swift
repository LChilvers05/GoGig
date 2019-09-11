//
//  ActivityFeedVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 22/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

//NEED TO FIX BUG WHERE USER CAN OBSERVE PORTFOLIO BY CLICKING ON DATE IN THE 'MY EVENTS' SECTION

class ActivityFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedCVCell: Int = 0 //Initially Notifications
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
    var usersEvents = [GigEvent]()
    var eventIDs = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupView()
        setupMenuBar()
        feedGateOpen = false
        refreshActivityFeed()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.topItem?.title = "Activity"
    }
    override func viewDidAppear(_ animated: Bool) {
        if observeGateOpen {
            observeGateOpen = false
            observeActivityNotifications()
        }
        if feedGateOpen {
            //Need to remove all on sign in otherwise it doesn't refresh
            //what has been 'observed' since view did load
            activityNotifications.removeAll()
            usersEvents.removeAll()
            eventIDs.removeAll()
            feedGateOpen = false
            refreshActivityFeed()
        }
    }
    
    //MARK: FETCH DATA
    func refreshActivityFeed() {
        if let uid = Auth.auth().currentUser?.uid {
            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                self.user = returnedUser
                
                //Get the Activity Notifications
                self.fetchingMore = true
                DataService.instance.getDBActivityFeed(uid: uid, currentActivity: self.activityNotifications) { (returnedActivityNotifications) in
                    self.activityNotifications = returnedActivityNotifications
                    print("Got back \(self.activityNotifications.count)")
                    
                    self.endReached = (returnedActivityNotifications.count == 0)
                    self.fetchingMore = false
                    
                    self.collectionView.reloadData()
                    
                }
                    
                //Get and Observe the User Event Recordings
                eventsHandle = DataService.instance.REF_USERS.child(uid).child("events").observe(.value) { (snapshot) in
                    DataService.instance.getDBUserEvents(uid: uid) { (returnedEventIDs) in
                        var eventListings = [GigEvent]()
                        //HERE DO THE CHECK TO SEE IF THE EVENT STILL EXISTS
                        //IF NOT THEN DELETE IT FROM THE USER EVENT LISTING
                        for eventID in returnedEventIDs {
                            DataService.instance.getDBSingleEvent(uid: uid, eventID: eventID) { (returnedGigEvent) in
                                
                                eventListings.insert(returnedGigEvent, at: 0)
                                self.usersEvents = eventListings
                                self.collectionView.reloadData()
                            }
                        }
                        self.eventIDs = returnedEventIDs
                    }
                }
            }
        }
    }
    
    //MARK: NOTIFICATION CELL
    
    func updateNotificationData(cell: ActivityFeedCell, row: Int) {
        cell.notificationImage.isHidden = false
        cell.eventNameButton.setTitle(activityNotifications[row].getSenderName(), for: .normal)
        cell.eventNameButton.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
        cell.eventNameButton.tag = row
        cell.deleteNotificationButton.tag = row
        cell.notificationDescriptionLabel.text = activityNotifications[row].getNotificationDescription()
        
        loadImageCache(url: activityNotifications[row].getNotificationPicURL(), isImage: true) { (returnedImage) in
            cell.notificationImage.image = returnedImage
        }
        
        if editingNotifications {
            cell.deleteNotificationButton.isHidden = false
        } else {
            cell.deleteNotificationButton.isHidden = true
        }
    }
    
    //MARK: NOTIFICATION CELL ACTIONS
    var checkUid: String?
    @IBAction func checkOut(_ sender: UIButton) {
        let row = sender.tag
        //Notifications Section
        if selectedCVCell == 0 {
            
            checkUid = activityNotifications[row].getSenderUid()
            
            performSegue(withIdentifier: TO_CHECK_PORTFOLIO, sender: nil)
        } else {
            //do nothing
        }
    }
    
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
    
    //MARK: OBSERVE ACTIVITY CHANGES
    
    func observeActivityNotifications(){
        if let uid = Auth.auth().currentUser?.uid {
            //Observe Activity Notfications
            DataService.instance.observeDBActivityFeed(uid: uid) { (returnedActivityNotification) in
                if self.activityNotifications.contains(returnedActivityNotification) == false {
                    self.activityNotifications.insert(returnedActivityNotification, at: 0)
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    
    //MARK: EVENT CELL
    
    func updateEventListingData(cell: ActivityFeedCell, row: Int) {
        cell.eventNameButton.setTitle("\(usersEvents[row].getMonthYearDate())\(usersEvents[row].getDayDate())", for: .normal)
        cell.eventNameButton.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
        cell.notificationDescriptionLabel.text = "\(usersEvents[row].getTitle())"
        cell.deleteNotificationButton.tag = row
        loadImageCache(url: usersEvents[row].getEventPhotoURL(), isImage: true) { (returnedImage) in
            cell.notificationImage.image = returnedImage
        }
        
        if editingNotifications {
            cell.deleteNotificationButton.isHidden = false
        } else {
            cell.deleteNotificationButton.isHidden = true
        }
    }
    
    //MARK: COMPARE TIME AND DATE
    
    func compareTime(gigEventToCompare: GigEvent) -> Bool {
        let dateObject = Date()
        let currentDate = dateObject.addingTimeInterval(3600) //hour behind
        
        //if the date of the GigEvent is old (less than the current date)
        if gigEventToCompare.getDate() < currentDate {
            return true
        }
        return false
    }
    
    //MARK: DELETE EVENTS
    
    var editingNotifications = false
    @IBAction func editBarButtonItem(_ sender: Any) {
        if editingNotifications {
            editingNotifications = false
            editBarButton.title = "Edit"
            collectionView.reloadData()
        } else {
            editingNotifications = true
            editBarButton.title = "Done"
            collectionView.reloadData()
        }
    }
    
    @IBAction func deleteNotification(_ sender: UIButton) {
        let row = sender.tag
        //If Organiser, then delete the public event from the database
        if selectedCVCell == 0 {
            activityNotifications.remove(at: row)
            DataService.instance.deleteDBActivityFeed(uid: user!.uid, notificationID: activityNotifications[row].getId())
            collectionView.reloadData()
        //Delete an Event Listing
        } else {
            var title = ""
            var message = ""
            if user!.gigs {
                title = "Delete this Gig"
                message = "You will have no association with this event"
            } else {
                title = "Delete this Event"
                message = "Your Event will no longer exist to all users"
            }
            //IMPROVE: The listings will not delete under the musician in database
            //if the organiser deleted them first
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (buttonPressed) in
                self.usersEvents.remove(at: row)
                if self.user!.gigs == false {
                    DataService.instance.deleteDBEvents(uid: self.user!.uid, eventID: self.eventIDs[row])
                }
                self.eventIDs.remove(at: row)
                DataService.instance.deleteDBUserEvents(uid: self.user!.uid, eventIDs: self.eventIDs)
                self.collectionView.reloadData()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //We cannot just delete from an array in firebase,
    //We need to upload a new modified array
//    func deleteGigEvent(gigEventForDeletion: GigEvent) {
//        print("Delete called")
//
//        //IMPROVE: The listings will not delete under the musician in database
//        // if the organiser deleted them first
//
//        //Delete all local recordings of the events in the database
//        let index = eventListings.firstIndex(of: gigEventForDeletion)
//
//        eventListings.remove(at: index!)
//        eventIDs.remove(at: index!)
//        DataService.instance.deleteDBUserEvents(uid: user!.uid, eventIDs: eventIDs)
//
//        //Check to see if it is an organiser
//        //authorised to delete the public events
//        if user!.gigs == false {
//            //Delete the public event object
//            DataService.instance.deleteDBEvents(uid: user!.uid, eventID: gigEventForDeletion.getid())
//            //Delete the private event listing under user (with an index)
//
//            //Delete the picture file that goes with the event
//            DataService.instance.deleteSTFile(uid: user!.uid, directory: "events", fileID: gigEventForDeletion.getid())
//        }
//    }
    
    //MARK: SEGUES
    
    var selectedApplication: ActivityNotification?
    var selectedListing: GigEvent?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_CHECK_PORTFOLIO {
            
            let userAccountVC = segue.destination as! UserAccountVC
            
            let backItem = UIBarButtonItem()
            backItem.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            userAccountVC.uid = checkUid!
            userAccountVC.observingPortfolio = true
            userAccountVC.refreshPortfolio()
            
        } else if segue.identifier == TO_REVIEW_APPLICATION {
            
            let reviewApplicationVC = segue.destination as! ReviewApplicationVC
            
            reviewApplicationVC.uid = checkUid!
            reviewApplicationVC.application = selectedApplication
            reviewApplicationVC.refresh()
            
        } else if segue.identifier == TO_EVENT_DESCRIPTION_2 {
            
            let eventDescriptionVC = segue.destination as! EventDescriptionVC
            eventDescriptionVC.gigEvent = selectedListing
        }
    }
}
