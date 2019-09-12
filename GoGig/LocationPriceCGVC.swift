//
//  LocationPriceCGVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 18/06/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import CoreLocation

//TODO: AFTER CAMP, ADD LOCATION SERVICES TO SORT GIGS WHEN PRESENTED TO THE MUSICIAN

class LocationPriceCGVC: AutoComplete, CLLocationManagerDelegate {
    
    @IBOutlet weak var confirmationImageView: UIImageView!
    @IBOutlet weak var locationNameField: MyTextField!
    @IBOutlet weak var postcodeField: MyTextField!
    @IBOutlet weak var paymentField: MyTextField!
    
    var user: User?
    var eventData: Dictionary<String, Any>?
    let locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        //To nearest hundred metres, to save battery
        lm.desiredAccuracy = kCLLocationAccuracyHundredMeters
        lm.requestWhenInUseAuthorization()
        return lm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        setupCGView()
        postcodeField.updateCharacterLimit(limit: 8)
        locationNameField.updateCharacterLimit(limit: 64)
        
        locationNameField.text = "Location_Name"
    }
    override func viewDidDisappear(_ animated: Bool) {
        //stop updating when view dissapears to conserve battery life
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: GET LOCATION
    var currentLocationOn = false
    @IBAction func useCurrentLocation(_ sender: Any) {
        if currentLocationOn == false  {
            currentLocationOn = true
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            confirmationImageView.image = UIImage(named: "acceptUser")
            confirmationImageView.isHidden = false
        } else {
            currentLocationOn = false
            locationManager.stopUpdatingLocation()
            eventLatitude = 0.00
            eventLongitude = 0.00
            confirmationImageView.image = UIImage(named: "rejectUser")
        }
    }
    
    var eventLatitude =  0.00
    var eventLongitude = 0.00
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        eventLatitude = userLocation.coordinate.latitude
        eventLongitude = userLocation.coordinate.longitude
    }
    
    @IBAction func searchLocationName(_ sender: Any) {
        presentAutocompleteVC()
        locationNameField.text = locationResult
    }
    
    @IBAction func continueButton(_ sender: Any) {
        
        if let locationName = locationNameField.text {
            if let postcode = postcodeField.text {
                if let strPayment = paymentField.text {
                    
                    if locationName.count > 2 {
                        if (postcode.count == 7 || postcode.count == 8) {
                            if let payment = Double(strPayment) {
                                
                                self.eventData!["latitude"] = eventLatitude
                                self.eventData!["longitude"] = eventLongitude
                                self.eventData!["locationName"] = locationName
                                self.eventData!["postcode"] = postcode
                                self.eventData!["payment"] = payment
                                
                                performSegue(withIdentifier: TO_INFO_CONTACT, sender: nil)
                                
                            } else {
                                
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
            
        }
    }
}

