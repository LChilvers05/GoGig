//
//  LocationPriceCGVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 18/06/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class LocationPriceCGVC: UIViewController {
    
    
    @IBOutlet weak var postcodeField: MyTextField!
    @IBOutlet weak var paymentField: MyTextField!
    
    var user: User?
    var eventData: Dictionary<String, Any>?
    
    var location = "home"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        postcodeField.updateCharacterLimit(limit: 8)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(eventData!)
    }
    
    @IBAction func continueButton(_ sender: Any) {
        
        if let postcode = postcodeField.text {
            if let strPayment = paymentField.text {
                
                if (postcode.count == 7 || postcode.count == 8) {
                    if let payment = Double(strPayment) {
                        
                        self.eventData!["location"] = ""
                        self.eventData!["postcode"] = postcode
                        self.eventData!["payment"] = payment
                        
                        performSegue(withIdentifier: TO_INFO_CONTACT, sender: nil)
                        
                    } else {
                        
                        displayError(title: "Payment", message: "Please enter the chosen amount in a suitable format")
                    }
                    
                } else {
                    
                    displayError(title: "Postcode", message: "Please enter the correct 7 character postcode of the event")
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

