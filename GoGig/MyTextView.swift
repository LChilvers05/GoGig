//
//  MyTextView.swift
//  GoGig
//
//  Created by Lee Chilvers on 06/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class MyTextView: UITextView {
    
    //delegation is a design pattern that enables a class or structure to hand off (or delegate) some of its responsibilities to an instance of another type
    let textViewDelegate = TextViewDelegate()
    var placeholder: String?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //set the delegate so that I can control placeholder
        self.delegate = textViewDelegate
        placeholder = textViewDelegate.placeholder
    }
    
    //customisation goes here
    override func awakeFromNib() {
        clipsToBounds = true
        layer.cornerRadius = 15.0
        backgroundColor = #colorLiteral(red: 0.9652684959, green: 0.9729685758, blue: 1, alpha: 1)
    }
    
    //set the placeholder
    func updatePlaceholder(placeholder: String) {
        textViewDelegate.placeholder = placeholder
    }
}
//to allow access to the editing delegate methods
class TextViewDelegate: NSObject, UITextViewDelegate {
    
    var placeholder = ""
    
    //clear the placeholder when editing
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            //text is now black
            textView.textColor = UIColor.black
        }
    }
    //if empty, add the placeholder
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeholder
            //text is back to gray
            textView.textColor = UIColor.lightGray
        }
    }
}


