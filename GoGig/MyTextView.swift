//
//  MyTextView.swift
//  GoGig
//
//  Created by Lee Chilvers on 06/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class MyTextView: UITextView {
    
    let textViewDelegate = TextViewDelegate()
    var placeholder: String?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = textViewDelegate
        
        placeholder = textViewDelegate.placeholder
    }
    
    //customisation goes here
    override func awakeFromNib() {
        clipsToBounds = true
        layer.cornerRadius = 15.0
        layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        backgroundColor = #colorLiteral(red: 0.9652684959, green: 0.9729685758, blue: 1, alpha: 1)
        font = .systemFont(ofSize: 15)
        
    }
    
    func updatePlaceholder(placeholder: String) {
        textViewDelegate.placeholder = placeholder
    }
}
//To allow access to the editing delegate methods
class TextViewDelegate: NSObject, UITextViewDelegate {
    
    var placeholder = ""
    
    //Clear the placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    //If empty add the placeholder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.lightGray
        }
    }
}


