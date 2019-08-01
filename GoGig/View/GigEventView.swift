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
        layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.5
        layer.cornerRadius = 10.0
        backgroundColor = #colorLiteral(red: 0.9467699272, green: 0.9392132586, blue: 0.9901848033, alpha: 1)
    }
}
