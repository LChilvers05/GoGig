//
//  MyTextField.swift
//  GoGig
//
//  Created by Lee Chilvers on 16/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class MyTextField: UITextField {
    
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
        backgroundColor = UIColor.white.withAlphaComponent(0.7)
        font = .systemFont(ofSize: 15)
    }
    
    func updateCharacterLimit(limit: Int) {
        textFieldDelegate.characterLimit = limit
    }
}
//To allow access to the editing delegate methods
class TextFieldDelegate: NSObject, UITextFieldDelegate {
    
    var characterLimit = 100
    
    //Put a limit on the number of characters allowed to be entered in the textField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        return count <= characterLimit
    }
    
}
