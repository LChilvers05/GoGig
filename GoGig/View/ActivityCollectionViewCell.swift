//
//  ActivityCollectionViewCell.swift
//  GoGig
//
//  Created by Lee Chilvers on 25/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class ActivityCVCell: UICollectionViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var feedTableView: UITableView!
    
    //Delegate methods for the table view in the collection view cell
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityFeedCell", for: indexPath) as! ActivityFeedCell
        
        cell.notificationDescriptionLabel.text = "Hello There From Lee"
        cell.eventNameButton.setTitle("Hello There", for: .normal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped a cell")
    }
    
    
}
