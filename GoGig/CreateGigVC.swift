//
//  CreateGig.swift
//  GoGig
//
//  Created by Lee Chilvers on 12/05/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

//  Now add UI to create a gig and upload to Firebase

import UIKit

class CreateGigVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCGView()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    let eventData = ["uid": "", "eventID": "", "title": "", "timestamp": "", "latitude": 0.00, "longitude": 0.00, "locationName": "", "postcode": "", "payment": 0.00, "description": "", "name": "", "email": "", "phone": "", "eventPhotoURL": "", "appliedUsers": [String: Bool].self] as [String : Any]
    
    @IBAction func continueButton(_ sender: Any) {
        
        performSegue(withIdentifier: TO_TITLE_DATE, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TO_TITLE_DATE {
            let titleDateCGVC = segue.destination as! TitleDateCGVC
            titleDateCGVC.eventData = self.eventData
        }
    }
}

