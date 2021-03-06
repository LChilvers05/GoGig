//
//  LocationPriceCGVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 18/06/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import CoreLocation

//is subclass of AutoComplete to inherit function to present Google Places view
class LocationPriceCGVC: AutoComplete, CLLocationManagerDelegate {
    
    @IBOutlet weak var confirmationImageView: UIImageView!
    @IBOutlet weak var locationNameField: MyTextField!
    @IBOutlet weak var postcodeField: MyTextField!
    @IBOutlet weak var paymentField: MyTextField!
    
    //editing
    var editingGate = true
    var gigEvent: GigEvent?
    
    var user: User?
    var eventData: Dictionary<String, Any>?
    let locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        //to nearest hundred metres to save battery
        lm.desiredAccuracy = kCLLocationAccuracyHundredMeters
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        hideKeyboard()
        //input restrictions
        postcodeField.updateCharacterLimit(limit: 8)
        locationNameField.updateCharacterLimit(limit: 64)
    }
    override func viewDidDisappear(_ animated: Bool) {
        //stop updating when view dissapears to conserve battery life
        locationManager.stopUpdatingLocation()
    }
    override func viewDidAppear(_ animated: Bool) {
        //if editing
        if editingGate && editingGigEvent && gigEvent != nil {
            //if the user chose to use the location services
            if !(gigEvent?.getLongitude() == 0.00 && gigEvent?.getLatitude() == 0.00) {
                //continue to use them
                useCurrentLocation(true)
            }
            //auto fill from the GigEvent object
            locationNameField.text = gigEvent?.getLocationName()
            postcodeField.text = gigEvent?.getPostcode()
            paymentField.text = String(gigEvent!.getPayment())
            
            editingGate = false
        }
    }
    
    //MARK: GET LOCATION
    var currentLocationOn = false
    @IBAction func useCurrentLocation(_ sender: Any) {
        //start updating location
        if currentLocationOn == false  {
            currentLocationOn = true
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            //show it's being used
            confirmationImageView.alpha = 1.0
            confirmationImageView.isHidden = false
        //stop updating the location
        } else {
            currentLocationOn = false
            locationManager.stopUpdatingLocation()
            //set coordinates back to zero if they
            //don't want to use location
            eventLatitude = 0.00
            eventLongitude = 0.00
            //show it's not being used
            confirmationImageView.alpha = 0.3
        }
    }
    
    var eventLatitude =  0.00
    var eventLongitude = 0.00
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //grab the most up to date coordinates (first in array)
        let userLocation: CLLocation = locations[0]
        eventLatitude = userLocation.coordinate.latitude
        eventLongitude = userLocation.coordinate.longitude
    }
    
    //info about user location usage
    @IBAction func locationInfoButton(_ sender: Any) {
        displayError(title: "Using Current Location", message: "will make your event appear first to applicants nearby")
    }
    
    //search and return location String with Google Places API
    @IBAction func searchLocationName(_ sender: Any) {
        presentAutocompleteVC()
        locationNameField.text = locationResult
    }
    
    @IBAction func continueButton(_ sender: Any) {
        
        if let locationName = locationNameField.text {
            if let postcode = postcodeField.text {
                if let strPayment = paymentField.text {
                    //validation
                    if locationName.count > 2 {
                        if (postcode.count == 7 || postcode.count == 8) {
                            //check payment can be made into a Double data type
                            if let payment = Double(strPayment) {
                                //add inputs to dictionary
                                self.eventData!["latitude"] = eventLatitude
                                self.eventData!["longitude"] = eventLongitude
                                self.eventData!["locationName"] = locationName
                                self.eventData!["postcode"] = postcode
                                self.eventData!["payment"] = payment
                                
                                performSegue(withIdentifier: TO_INFO_CONTACT, sender: nil)
                                
                            } else {
                                //cannot be converted to Double
                                displayError(title: "Payment", message: "Please enter the chosen amount in a suitable format")
                            }
                            
                        } else {
                            
                            displayError(title: "Postcode", message: "Please enter the correct 7 character postcode of the event")
                        }
                        
                    } else {
                        
                        displayError(title: "Location", message: "Please search for or type in a location")
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == TO_INFO_CONTACT {
            
            let infoContactCGVC = segue.destination as! InfoContactCGVC
            
            infoContactCGVC.user = user
            infoContactCGVC.eventData = eventData
            infoContactCGVC.gigEvent = gigEvent
            infoContactCGVC.editingGate = true
        }
    }
}

