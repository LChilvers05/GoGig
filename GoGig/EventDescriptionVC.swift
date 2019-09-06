//
//  EventDescriptionVC.swift
//  GoGig
//
//  Created by Lee Chilvers on 01/08/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class EventDescriptionVC: UIViewController {
    
    @IBOutlet weak var gigTitleLabel: UILabel!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var dayDateLabel: UILabel!
    @IBOutlet weak var monthYearDateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var descriptionTextView: MyTextView!
    
    var gigEvent: GigEvent?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false
        
        refresh()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func refresh() {
        navigationController?.navigationBar.topItem?.title = gigEvent?.getName()
        gigTitleLabel.text = gigEvent?.getTitle()
        nameButton.setTitle("Check out \(gigEvent!.getName())", for: .normal)
        dayDateLabel.text = gigEvent?.getDayDate()
        monthYearDateLabel.text = gigEvent?.getLongMonthYearDate()
        timeLabel.text = gigEvent?.getTime()
        locationLabel.text = gigEvent!.getLocationName() + " " + gigEvent!.getPostcode()
        paymentLabel.text = "For: £\(gigEvent!.getPayment())"
        descriptionTextView.text = gigEvent?.getDescription()
    }
    
    var checkUid: String?
    @IBAction func checkUid(_ sender: Any) {
        checkUid = gigEvent?.getuid()
        performSegue(withIdentifier: TO_CHECK_PORTFOLIO_3, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TO_CHECK_PORTFOLIO_3 {
            
            let userAccountVC = segue.destination as! UserAccountVC
            
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            userAccountVC.uid = checkUid!
            userAccountVC.observingPortfolio = true
            userAccountVC.refreshPortfolio()
        }
    }
}
