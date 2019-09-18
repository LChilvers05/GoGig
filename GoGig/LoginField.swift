//
//  LoginField.swift
//  GoGig
//
//  Created by Lee Chilvers on 26/01/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class LoginField: UITextField {
    
    let textFieldDelegate = TextFieldDelegate()
    var characterLimit: Int?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        self.delegate = textFieldDelegate
        
        characterLimit = textFieldDelegate.characterLimit
        
    }
    
    //customisation goes here
    override func awakeFromNib() {
        clipsToBounds = true
        layer.cornerRadius = self.frame.size.height/2
        layer.borderWidth = 2.0
        layer.borderColor = #colorLiteral(red: 0.9652684959, green: 0.9729685758, blue: 1, alpha: 1)
        //backgroundColor = #colorLiteral(red: 0.9652684959, green: 0.9729685758, blue: 1, alpha: 1)
        backgroundColor = UIColor.white.withAlphaComponent(0.1)
        font = .systemFont(ofSize: 15)
    }
    
    func updateCharacterLimit(limit: Int) {
        textFieldDelegate.characterLimit = limit
    }
}

