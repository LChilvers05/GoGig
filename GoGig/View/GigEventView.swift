//
//  GigEventView.swift
//  
//
//  Created by Lee Chilvers on 17/07/2019.
//

import UIKit

class GigEventView: UIView {
    
    @IBOutlet weak var dayDateLabel: UILabel!
    @IBOutlet weak var monthYearDateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var eventPhotoImageView: UIImageView!
    
    override func awakeFromNib() {
        //rounded corners like shape of card
        layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.5
        layer.cornerRadius = 10.0
        //create a gradient of stops orange to purple
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(red: 255.0/255.0, green: 159.0/255.0, blue: 2.0/255.0, alpha: 0.5).cgColor, UIColor(red: 104.0/255.0, green: 35.0/255.0, blue: 128.0/255.0, alpha: 0.6).cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
        gradient.cornerRadius = 10.0
        self.layer.insertSublayer(gradient, at: 0)
        
    }
}
