//
//  StringExtensions.swift
//  GoGig
//
//  Created by Lee Chilvers on 18/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation

extension String {
    
    //Swift string extension (like Java)
    func substring(start: Int, end: Int) -> String {
        //the start index
        let start = self.index(self.startIndex, offsetBy: start)
        //the end index
        let end = self.index(self.startIndex, offsetBy: end)
        //the range from start to end
        let range = start..<end
        //create a substring from the range
        let mySubstring = self[range]
        //instantiate a string object from substring
        let returnString = String(mySubstring)
        //return the new string
        return returnString
    }
}
