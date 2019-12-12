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

class ActivityFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate {
    
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
        self.tabBarController?.delegate = self
        setupMenuBar()
        feedGateOpen = false
        refreshActivityFeed()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAll), name: NSNotification.Name(rawValue: "refreshAllActivity"), object: nil)
        
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
    @objc func refreshAll() {
        print("=====================================")
        print("Refreshed the activity after the edit")
        activityNotifications.removeAll()
        usersEvents.removeAll()
        eventIDs.removeAll()
        self.collectionView.reloadData()
        refreshActivityFeed()
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
                        //One was getting appended, the other was getting inserted at 0.  Deleting didn't delete the correct gigEvent
                        self.eventIDs = returnedEventIDs.reversed()
                        //Iterate through the list of eventIDs associated to user, get each one from public events
                        //And insert at 0 of local array
                        for eventID in returnedEventIDs {
                            DataService.instance.getDBSingleEvent(uid: uid, eventID: eventID) { (returnedGigEvent, success)  in
                                if success {
                                    eventListings.insert(returnedGigEvent, at: 0)
                                    self.usersEvents = eventListings
                                    self.collectionView.reloadData()
                                    self.attemptReload()
                                
                                    //Couldn't get GigEvent
                                } else {
                                    //User (should be musician) has an eventID listed which the organiser has already deleted the event, clean up the DB
                                    if let index = self.eventIDs.firstIndex(of: eventID) {
                                        self.eventIDs.remove(at: index)
                                        DataService.instance.deleteDBUserEvents(uid: uid, eventIDs: self.eventIDs)
                                    }
                                }
                                self.attemptReload()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Needed so that the user profile pictures don't flash and display the wrong image
    var timer: Timer?
    func attemptReload() {
        //Stop the timer
        self.timer?.invalidate()
        //Reload the collection view and all its data 0.1 seconds after timer has started
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReload), userInfo: nil, repeats: false) //Doesn't repeat
    }
    @objc func handleReload(){
        self.collectionView.reloadData()
    }
    
    //MARK: FETCH MORE DATA
    //(Pagination)
    
    var fetchingMore = false
    //If reached the end, don't bother fetching anymore posts
    var endReached = false
    //Start loading notifications 1 cell in advance
    var leadingScreensForBatching: CGFloat = 1.0
    
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
    
    //MARK: NOTIFICATION CELL
    
    func updateNotificationData(cell: ActivityFeedCell, row: Int) {
        //Bug of cell repeat
        cell.notificationImage.alpha = 1
        cell.eventNameButton.isEnabled = true
        cell.eventNameButton.alpha = 1
        cell.notificationDescriptionLabel.alpha = 1
        
        //cell.notificationImage.isHidden = false
        cell.eventNameButton.setTitle(activityNotifications[row].getSenderName(), for: .normal)
        cell.eventNameButton.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
        cell.eventNameButton.tag = row
        cell.deleteNotificationButton.tag = row
        cell.notificationDescriptionLabel.text = activityNotifications[row].getNotificationDescription()
        
        loadImageCache(url: activityNotifications[row].getNotificationPicURL(), isImage: true) { (returnedImage) in
            cell.notificationImage.image = nil
            cell.notificationImage.image = returnedImage
        }
        
        if editingNotifications {
            cell.deleteNotificationButton.isHidden = false
        } else {
            cell.deleteNotificationButton.isHidden = true
        }
    }
    
    //MARK: EVENT CELL
    
    func updateEventListingData(cell: ActivityFeedCell, row: Int) {
        //Bug of cell repeat
        cell.notificationImage.alpha = 1
        cell.eventNameButton.isEnabled = true
        cell.eventNameButton.alpha = 1
        cell.notificationDescriptionLabel.alpha = 1
        
        cell.notificationImage.isHidden = false
        cell.eventNameButton.setTitle("\(usersEvents[row].getMonthYearDate())-\(usersEvents[row].getDayDate())", for: .normal)
        cell.eventNameButton.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
        cell.notificationDescriptionLabel.text = "\(usersEvents[row].getTitle())"
        cell.eventNameButton.tag = row
        cell.deleteNotificationButton.tag = row
        loadImageCache(url: usersEvents[row].getEventPhotoURL(), isImage: true) { (returnedImage) in
            cell.notificationImage.image = returnedImage
        }
        
        if editingNotifications {
            cell.deleteNotificationButton.isHidden = false
        } else {
            cell.deleteNotificationButton.isHidden = true
        }
        
        //If old event change the UI
        if checkOld(gigEventToCompare: usersEvents[row]) == true {
            cell.notificationImage.alpha = 0.3
            cell.eventNameButton.isEnabled = false
            cell.eventNameButton.alpha = 0.3
            cell.notificationDescriptionLabel.alpha = 0.3
        }
    }
    
    //MARK: NOTIFICATION CELL ACTIONS
    var checkUid: String?
    @IBAction func checkOut(_ sender: UIButton) {
        //Get the row of the cell with a tag
        let row = sender.tag
        //Notifications Section
        if selectedCVCell == 0 {
            //and get the uid of user that sent the notification
            checkUid = activityNotifications[row].getSenderUid()
            //perform segue to observe portfolio refreshed with this uid
            performSegue(withIdentifier: TO_CHECK_PORTFOLIO, sender: nil)
        
        //My Events Section
        } else {
            //Get the GigEvent object
            let calendarEvent = usersEvents[row]
            //Use it to add an event to the calendar
            addEventToCalendar(title: calendarEvent.getTitle(), description: calendarEvent.getDescription(), startDate: calendarEvent.getDate().addingTimeInterval(-3600), endDate: calendarEvent.getDate())
            //Notifiy the user that it has been added
            displayError(title: "Added to Calendar", message: "This event was added to your device calendar")
        }
    }
    
    //MARK: COMPARE TIME AND DATE
    
    func checkOld(gigEventToCompare: GigEvent) -> Bool {
        //Get current date...
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
        //Delete a notification
        if selectedCVCell == 0 {
            DataService.instance.deleteDBActivityFeed(uid: user!.uid, notificationID: activityNotifications[row].getId())
            activityNotifications.remove(at: row)
            collectionView.reloadData()
        //Delete an Event Listing
        } else {
            //Provide a warning message
            var title = ""
            var message = ""
            //Warn the musician
            if user!.gigs {
                title = "Forget the Gig"
                message = "You will have no association with this event"
            //Warn the organiser
            } else {
                title = "Delete your Event"
                message = "It will no longer exist to all users"
            }
            //Add the UIAlerts
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (buttonPressed) in
                //If organiser, delete the event object and the picture in Storage
                if self.user!.gigs == false {
                    DataService.instance.deleteDBEvents(uid: self.user!.uid, eventID: self.eventIDs[row])
                    DataService.instance.deleteSTFile(uid: self.user!.uid, directory: "events", fileID: self.eventIDs[row])
                }
                //For everyone remove it from event listings under user in database
                self.eventIDs.remove(at: row)
                self.usersEvents.remove(at: row)
                DataService.instance.deleteDBUserEvents(uid: self.user!.uid, eventIDs: self.eventIDs)
                self.collectionView.reloadData()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //Pressed the tab, scroll to the top of the table view
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
         let tabBarIndex = tabBarController.selectedIndex
         if tabBarIndex == 2 {
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scrollToTop"), object: nil)
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
            
            let backItem = UIBarButtonItem()
            backItem.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            let eventDescriptionVC = segue.destination as! EventDescriptionVC
            eventDescriptionVC.gigEvent = selectedListing
            eventDescriptionVC.observingGigEvent = user!.gigs
        }
    }
}
