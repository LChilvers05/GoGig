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

class ActivityFeedVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate {
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedCVCell: Int = 0 //initially show notifications
    var storedOffsets = [Int: CGFloat]()
    
    //instantiation of menubar in a closure
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.translatesAutoresizingMaskIntoConstraints = false
        mb.activityFeedVC = self
        return mb
    }()
    
    private func setupMenuBar() {
        //dont show the scroll bar for horizontal scroll
        collectionView.showsHorizontalScrollIndicator = false
        //so scroll will stop on either cell and not sit halfway between them
        collectionView.isPagingEnabled = true
        //constrain the menuBar to the top of the collectionview
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
        //to refresh activity in other classes
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAll), name: NSNotification.Name(rawValue: "refreshAllActivity"), object: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.topItem?.title = "Activity"
    }
    override func viewDidAppear(_ animated: Bool) {
        //so multiple observers aren't opened when view appears
        if observeGateOpen {
            observeGateOpen = false
            observeActivityNotifications()
        }
        //so feed doesn't refresh everytime view appears
        if feedGateOpen {
            //need to remove all on sign in otherwise it doesn't refresh
            //what has been 'observed' since view did load
            activityNotifications.removeAll()
            usersEvents.removeAll()
            eventIDs.removeAll()
            feedGateOpen = false
            refreshActivityFeed()
        }
    }
    @objc func refreshAll() {
        //will be called after editing an event
        //clear everything
        activityNotifications.removeAll()
        usersEvents.removeAll()
        eventIDs.removeAll()
        //reload the collectionview
        self.collectionView.reloadData()
        //and refresh it again
        refreshActivityFeed()
    }
    
    //MARK: FETCH DATA
    func refreshActivityFeed() {
        //get the current user profile
        if let uid = Auth.auth().currentUser?.uid {
            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                self.user = returnedUser
                
                //get the Activity Notifications
                self.fetchingMore = true
                DataService.instance.getDBActivityFeed(uid: uid, currentActivity: self.activityNotifications) { (returnedActivityNotifications) in
                    self.activityNotifications = returnedActivityNotifications
                    //keep track of how many new ones were added (pagination)
                    print("Got back \(self.activityNotifications.count)")
                    //no more new notifications
                    self.endReached = (returnedActivityNotifications.count == 0)
                    //stop fetching more
                    self.fetchingMore = false
                    //reload the tables
                    self.collectionView.reloadData()
                }
                    
                //get and observe the events associate to that user
                eventsHandle = DataService.instance.REF_USERS.child(uid).child("events").observe(.value) { (snapshot) in
                    DataService.instance.getDBUserEvents(uid: uid) { (returnedEventIDs) in
                        var eventListings = [GigEvent]()
                        //one was getting appended, the other was getting inserted at 0.  deleting didn't delete the correct gigEvent
                        self.eventIDs = returnedEventIDs.reversed()
                        //iterate through the list of eventIDs associated to user, get each one from public events
                        //and insert at 0 of local array
                        for eventID in returnedEventIDs {
                            DataService.instance.getDBSingleEvent(uid: uid, eventID: eventID) { (returnedGigEvent, success)  in
                                if success {
                                    eventListings.insert(returnedGigEvent, at: 0)
                                    self.usersEvents = eventListings
                                    self.collectionView.reloadData()
                                    self.attemptReload()
                                
                                //couldn't get GigEvent (been deleted)
                                } else {
                                    //user (should be musician) has an eventID listed which the organiser has already deleted, clean up the DB
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
    
    //needed so that the user profile pictures don't flash and display the wrong image
    var timer: Timer?
    func attemptReload() {
        //stop the timer
        self.timer?.invalidate()
        //reload the collection view and all its data 0.1 seconds after timer has started
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReload), userInfo: nil, repeats: false) //doesn't repeat
    }
    @objc func handleReload(){
        self.collectionView.reloadData()
    }
    
    //MARK: FETCH MORE DATA
    //(Pagination)
    var fetchingMore = false
    //if reached the end, don't bother fetching anymore posts
    var endReached = false
    //start loading notifications 1 cell in advance
    var leadingScreensForBatching: CGFloat = 1.0
    
    func getMoreNotifications(){
        fetchingMore = true
        
        DataService.instance.getDBActivityFeed(uid: user!.uid, currentActivity: activityNotifications) { (returnedActivityNotifications) in
            //we are appending the contents of the array, not the array itself
            self.activityNotifications.append(contentsOf: returnedActivityNotifications)
            
            //if no more notifications, we have reached the end
            self.endReached = (returnedActivityNotifications.count == 0)
            self.fetchingMore = false
            self.collectionView.reloadData()
        }
    }
    
    //MARK: OBSERVE ACTIVITY CHANGES
    
    func observeActivityNotifications(){
        if let uid = Auth.auth().currentUser?.uid {
            //observe Activity Notfications
            DataService.instance.observeDBActivityFeed(uid: uid) { (returnedActivityNotification) in
                //double check it is a new notification
                if self.activityNotifications.contains(returnedActivityNotification) == false {
                    self.activityNotifications.insert(returnedActivityNotification, at: 0)
                }
                //reload to show new notification
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: NOTIFICATION CELL
    
    func updateNotificationData(cell: ActivityFeedCell, row: Int) {
        //bug of cell repeat
        cell.notificationImage.alpha = 1
        cell.eventNameButton.isEnabled = true
        cell.eventNameButton.alpha = 1
        cell.notificationDescriptionLabel.alpha = 1
        //set all the notification data in the cell
        cell.eventNameButton.setTitle(activityNotifications[row].getSenderName(), for: .normal)
        cell.eventNameButton.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
        cell.eventNameButton.tag = row
        cell.deleteNotificationButton.tag = row
        cell.notificationDescriptionLabel.text = activityNotifications[row].getNotificationDescription()
        //try load the image from cache
        loadImageCache(url: activityNotifications[row].getNotificationPicURL(), isImage: true) { (returnedImage) in
            cell.notificationImage.image = nil
            cell.notificationImage.image = returnedImage
        }
        //if user clicked edit, show the 'minus' delete buttons
        if editingNotifications {
            cell.deleteNotificationButton.isHidden = false
        } else {
            cell.deleteNotificationButton.isHidden = true
        }
    }
    
    //MARK: EVENT CELL
    
    func updateEventListingData(cell: ActivityFeedCell, row: Int) {
        //bug of cell repeat
        cell.notificationImage.alpha = 1
        cell.eventNameButton.isEnabled = true
        cell.eventNameButton.alpha = 1
        cell.notificationDescriptionLabel.alpha = 1
        //set all the event listing data in the cell
        cell.notificationImage.isHidden = false
        cell.eventNameButton.setTitle("\(usersEvents[row].getMonthYearDate())-\(usersEvents[row].getDayDate())", for: .normal)
        cell.eventNameButton.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
        cell.notificationDescriptionLabel.text = "\(usersEvents[row].getTitle())"
        cell.eventNameButton.tag = row
        cell.deleteNotificationButton.tag = row
        loadImageCache(url: usersEvents[row].getEventPhotoURL(), isImage: true) { (returnedImage) in
            cell.notificationImage.image = returnedImage
        }
        //only show delete if editing
        if editingNotifications {
            cell.deleteNotificationButton.isHidden = false
        } else {
            cell.deleteNotificationButton.isHidden = true
        }
        
        //if old event change the UI
        if checkOld(gigEventToCompare: usersEvents[row]) == true {
            //faded - set alpha to 0.3
            cell.notificationImage.alpha = 0.3
            //cannot iteract with the date button
            cell.eventNameButton.isEnabled = false
            cell.eventNameButton.alpha = 0.3
            cell.notificationDescriptionLabel.alpha = 0.3
        }
    }
    
    //MARK: NOTIFICATION CELL ACTIONS
    var checkUid: String?
    @IBAction func checkOut(_ sender: UIButton) {
        //get the row of the cell with a tag from button
        let row = sender.tag
        //notifications section
        if selectedCVCell == 0 {
            //and get the uid of user that sent the notification
            checkUid = activityNotifications[row].getSenderUid()
            //perform segue to observe portfolio refreshed with this uid
            performSegue(withIdentifier: TO_CHECK_PORTFOLIO, sender: nil)
        
        //'My Events' section
        } else {
            //get the GigEvent object
            let calendarEvent = usersEvents[row]
            //use it to add an event to the calendar
            addEventToCalendar(title: calendarEvent.getTitle(), description: calendarEvent.getDescription(), startDate: calendarEvent.getDate().addingTimeInterval(-3600), endDate: calendarEvent.getDate())
            //notifiy the user that it has been added
            displayError(title: "Added to Calendar", message: "This event was added to your device calendar")
        }
    }
    
    //MARK: COMPARE TIME AND DATE
    
    //to decide if event listing should be faded or not
    func checkOld(gigEventToCompare: GigEvent) -> Bool {
        //get current date
        let dateObject = Date()
        let currentDate = dateObject.addingTimeInterval(3600) //hour behind
        
        //if the date of the GigEvent is old (less than the current date)
        if gigEventToCompare.getDate() < currentDate {
            return true
        }
        return false
    }
    
    //MARK: DELETE EVENTS
    
    //user chossing to delete table cells
    var editingNotifications = false
    @IBAction func editBarButtonItem(_ sender: Any) {
        //change UI so user knows what is going on
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
        //delete a notification
        if selectedCVCell == 0 {
            DataService.instance.deleteDBActivityFeed(uid: user!.uid, notificationID: activityNotifications[row].getId())
            activityNotifications.remove(at: row)
            collectionView.reloadData()
        //delete an Event Listing
        } else {
            //provide a warning message
            var title = ""
            var message = ""
            //warn the musician
            if user!.gigs {
                title = "Forget the Gig"
                message = "You will have no association with this event"
            //warn the organiser
            } else {
                title = "Delete your Event"
                message = "It will no longer exist to all users"
            }
            //add the UIAlerts
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (buttonPressed) in
                //if organiser, delete the event object and the picture in Storage
                if self.user!.gigs == false {
                    DataService.instance.deleteDBEvents(uid: self.user!.uid, eventID: self.eventIDs[row])
                    DataService.instance.deleteSTFile(uid: self.user!.uid, directory: "events", fileID: self.eventIDs[row])
                }
                //for everyone remove it from event listings under user in Database
                self.eventIDs.remove(at: row)
                self.usersEvents.remove(at: row)
                DataService.instance.deleteDBUserEvents(uid: self.user!.uid, eventIDs: self.eventIDs)
                self.collectionView.reloadData()
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    //pressed the tab, scroll to the top of the table view
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
    
    //to keep track of what object belongs to the tapped cell
    var selectedApplication: ActivityNotification?
    var selectedListing: GigEvent?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //set up destination ready to observe portfolio
        if segue.identifier == TO_CHECK_PORTFOLIO {
            
            let userAccountVC = segue.destination as! UserAccountVC
            
            let backItem = UIBarButtonItem()
            backItem.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            userAccountVC.uid = checkUid!
            userAccountVC.observingPortfolio = true
            userAccountVC.refreshPortfolio()
        
        //setup destination ready to respond to application
        } else if segue.identifier == TO_REVIEW_APPLICATION {
            
            let reviewApplicationVC = segue.destination as! ReviewApplicationVC
            
            reviewApplicationVC.uid = checkUid!
            reviewApplicationVC.application = selectedApplication
            reviewApplicationVC.refresh()
        
        //setup destination ready to look at the GigEvent object in more detail
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
