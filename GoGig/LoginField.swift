//
//  LoginField.swift
//  GoGig
//
//  Created by Lee Chilvers on 26/01/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class LoginField: UITextField {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.borderWidth = 2
        self.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.layer.shadowColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        self.layer.shadowRadius = 10
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = 5
        
    }
    
}

