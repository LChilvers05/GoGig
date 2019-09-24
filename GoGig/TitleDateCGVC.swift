//
//  TitleDateCGVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 18/06/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

//  THINGS TO THINK ABOUT
//  Character limit on text fields
//  Adding a date before current time

class TitleDateCGVC: UIViewController {
    
    @IBOutlet weak var eventTitleField: MyTextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var user: User?
    var editingGate = true
    var editEventID = ""
    var gigEvent: GigEvent?
    
    var eventData: Dictionary<String, Any>?
    
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        hideKeyboard()
        
        eventTitleField.updateCharacterLimit(limit: 50)
        
        //Get the user
        if let uid = Auth.auth().currentUser?.uid {
            DataService.instance.getDBUserProfile(uid: uid) { (returnedUser) in
                self.user = returnedUser
            }
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz"
        
        //Set restrictions on the Date Picker
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        
        //Can only choose a date up to 10 years in advance
        components.year = 10
        components.month = 0
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        
        //Cannot choose date or time before current time
        components.year = 0
        let minDate = calendar.date(byAdding: components, to: currentDate)!
        
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewDidAppear(_ animated: Bool) {
        //We are creating not editing, this causes crash if user starts editing, then decides to create
        if self.tabBarController?.selectedIndex == 0 {
            editingGigEvent = false
        }
        if editingGigEvent && editingGate {
            if let uid = Auth.auth().currentUser?.uid {
                DataService.instance.getDBSingleEvent(uid: uid, eventID: editEventID) { (returnedGigEvent) in
                    let returnedGigEventData = ["uid": uid, "eventID": returnedGigEvent.getid(), "title": returnedGigEvent.getTitle(), "timestamp": returnedGigEvent.getTimestamp(), "latitude": returnedGigEvent.getLatitude(), "longitude": returnedGigEvent.getLongitude(), "locationName": returnedGigEvent.getLocationName(), "postcode": returnedGigEvent.getPostcode(), "payment": returnedGigEvent.getPayment(), "description": returnedGigEvent.getDescription(), "name": returnedGigEvent.getName(), "email": returnedGigEvent.getEmail(), "phone": returnedGigEvent.getPhone(), "eventPhotoURL": returnedGigEvent.getEventPhotoURL(), "appliedUsers": returnedGigEvent.getAppliedUsers()] as [String : Any]
                    self.eventData = returnedGigEventData
                    self.gigEvent = returnedGigEvent
                    self.eventTitleField.text = returnedGigEvent.getTitle()
                    let setDate = self.dateFormatter.date(from: returnedGigEvent.getTimestamp())
                    let date = setDate?.addingTimeInterval(-3600)
                    self.datePicker.setDate(date!, animated: false)
                    self.editingGate = false
                }
            }
        }
    }
    
    @IBAction func continueButton(_ sender: Any) {
        
        //let eventID = NSUUID().uuidString
        //will make the eventID the same as the imageID
        
        //Raw value from picker - Hour behind, add an hour (3600s)
        let chosenTime = datePicker.date.addingTimeInterval(3600)
        //string for FIR
        let timestamp = "\(chosenTime)"
        
        if let eventTitle = eventTitleField.text{
            if eventTitle != "" && eventTitle.count <= 60 {
                
                
                //eventData = ["uid": self.user?.uid as Any, "eventID": "", "title": eventTitle, "timestamp": timestamp, "latitude": 0.00, "longitude": 0.00, "locationName": "", "postcode": "", "payment": 0.00, "description": "", "name": "", "email": "", "phone": "", "eventPhotoURL": "", "appliedUsers": [String: Bool].self]
                self.eventData!["uid"] = self.user?.uid as Any
                self.eventData!["title"] = eventTitle
                self.eventData!["timestamp"] = timestamp
                
                performSegue(withIdentifier: TO_LOCATION_PRICING, sender: nil)
                
            } else {
                // User not added wrote a title
                displayError(title: "Add a title", message: "Please add the title of your event to continue")
            }
        }
    }
    
    //Take the eventDate through every view controller as user progresses
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_LOCATION_PRICING {
            
            //Need this line to pass information between view controllers
            let locationPriceCGVC = segue.destination as! LocationPriceCGVC
            
            //Changes it
            locationPriceCGVC.user = user
            locationPriceCGVC.eventData = eventData
            locationPriceCGVC.gigEvent = gigEvent
            locationPriceCGVC.editingGate = true
            
        }
    }
}

