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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    @IBAction func continueButton(_ sender: Any) {
        
        performSegue(withIdentifier: TO_TITLE_DATE, sender: nil)
    }
    
}

