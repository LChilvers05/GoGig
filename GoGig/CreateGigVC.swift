//
//  CreateGig.swift
//  GoGig
//
//  Created by Lee Chilvers on 12/05/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

// BUG WHERE AFTER PICKING A PHOTO AND PRESSING TAB BUTTON TO GO BACK TO THIS VC
// CAUSES CONSTRAINTS TO MESS UP

import UIKit

class CreateGigVC: UIViewController {
    
    @IBOutlet weak var descriptionStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    //Is in a navigation stack, hide bar as this is the root
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        //Bug after adding photo of the event and going back
        self.navigationController?.navigationBar.isHidden = true
    }
    //event data dictionary for Database
    let eventData = ["uid": "", "eventID": "", "title": "", "timestamp": "", "latitude": 0.00, "longitude": 0.00, "locationName": "", "postcode": "", "payment": 0.00, "description": "", "name": "", "email": "", "phone": "", "eventPhotoURL": "", "appliedUsers": [String: Bool].self] as [String : Any]
    
    @IBAction func continueButton(_ sender: Any) {
        
        performSegue(withIdentifier: TO_TITLE_DATE, sender: nil)
    }
    //take the dictionary and fill it from the forms and inputs
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TO_TITLE_DATE {
            let titleDateCGVC = segue.destination as! TitleDateCGVC
            titleDateCGVC.eventData = self.eventData
        }
    }
}

