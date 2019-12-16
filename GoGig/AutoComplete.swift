//
//  AutoComplete.swift
//  GoGig
//
//  Created by Lee Chilvers on 02/03/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class AutoComplete: UIViewController, GMSAutocompleteViewControllerDelegate {
    
    //default location string
    var locationResult = "Location"
    
    //present the VC
    func presentAutocompleteVC(){
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        //MUST PAY FOR API USAGE
        // specify the place data types to return
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields
        
        // specify a filter
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        
        // display the autocomplete view controller
        present(autocompleteController, animated: true, completion: nil)
    }
    
    // handle the user's selection
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        //location string is what user has chosen and returned
        locationResult = place.name!
        //dismiss the view
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        //handle the error if there is one
        print("Error: ", error.localizedDescription)
    }
    
    //user canceled the operation
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    //turn the network activity indicator on and off again
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

