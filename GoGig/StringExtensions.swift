//
//  StringExtensions.swift
//  GoGig
//
//  Created by Lee Chilvers on 18/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation

extension String {
    
    func substring(start: Int, end: Int) -> String {
        
        let start = self.index(self.startIndex, offsetBy: start)
        let end = self.index(self.startIndex, offsetBy: end)
        let range = start..<end
        
        let mySubstring = self[range]
        let returnString = String(mySubstring)
        
        return returnString
    }
}
