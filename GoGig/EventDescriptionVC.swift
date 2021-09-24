//
//  EventDescriptionVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 01/08/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class EventDescriptionVC: UIViewController {
    
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var dayDateLabel: UILabel!
    @IBOutlet weak var monthYearDateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var descriptionTextView: MyTextView!
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    
    //observing description (creator will have an edit button)
    var observingGigEvent = true
    
    var gigEvent: GigEvent?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        //show the navigation bar
        navigationController?.navigationBar.isHidden = false
        
        refresh()
    }
    override func viewWillAppear(_ animated: Bool) {
        //specifiy that large title is not wanted
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    override func viewDidAppear(_ animated: Bool) {
        //if musician observing event
        if observingGigEvent {
            //hide the edit button
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func refresh() {
        //set all outlets with information about the gig
        self.navigationItem.title = gigEvent?.getTitle()
        nameButton.setTitle("Check out \(gigEvent!.getName())", for: .normal)
        dayDateLabel.text = gigEvent?.getDayDate()
        monthYearDateLabel.text = gigEvent?.getLongMonthYearDate()
        timeLabel.text = gigEvent?.getTime()
        locationLabel.text = gigEvent!.getLocationName() + "  " + gigEvent!.getPostcode()
        paymentLabel.text = "For: £\(gigEvent!.getPayment())"
        descriptionTextView.text = gigEvent?.getDescription()
    }
    
    //look at the portfolio of the event creator
    var checkUid: String?
    @IBAction func checkUid(_ sender: Any) {
        //uid is to refresh portfolio of that user
        checkUid = gigEvent?.getuid()
        performSegue(withIdentifier: TO_CHECK_PORTFOLIO_3, sender: nil)
    }
    
    @IBAction func editGigEvent(_ sender: Any) {
        //if creator wants to edit
        if observingGigEvent == false {
            //globally declare that user is editing event
            editingGigEvent = true
            //and go back to create event navigation stack to edit the event
            self.performSegue(withIdentifier: TO_EDIT_GIG_EVENT, sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TO_CHECK_PORTFOLIO_3 {
            
            let userAccountVC = segue.destination as! UserAccountVC
            //add a back button in place of 'settings' in portfolio view
            let backItem = UIBarButtonItem()
            backItem.tintColor = #colorLiteral(red: 0.4942619801, green: 0.1805444658, blue: 0.5961503386, alpha: 1)
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            //uid needed to refresh portfolio for that user
            userAccountVC.uid = checkUid!
            //mark a user is observing that portfolio
            userAccountVC.observingPortfolio = true
            //refresh the portfolio ready for the segue
            userAccountVC.refreshPortfolio()
            
        } else if segue.identifier == TO_EDIT_GIG_EVENT {
            //set the create event views ready to edit the event
            let titleDateCGVC = segue.destination as! TitleDateCGVC
            titleDateCGVC.editEventID = gigEvent!.getid()
            titleDateCGVC.editingGate = true
        }
    }
}
