//
//  PortfolioPost.swift
//  GoGig
//
//  Created by Lee Chilvers on 06/03/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import Foundation
import UIKit

class PortfolioPost: Comparable {
    
    var uid: String             //user that owns post
    private var id: String      //unique identifier of post
    var location: String        //name of posts location
    var caption: String         //caption of post
    var isImage: Bool           //decide if post is image/video
    var postURL: URL            //image download URL
    var thumbnailURL: URL
    private var time: NSDate
    var dimensions: Dictionary<String, Any>
    
    init(uid: String, id: String, location: String, caption: String, isImage: Bool, postURL: URL, thumbnailURL: URL, time: NSDate, dimensions: Dictionary<String, Any>) {
        self.uid = uid
        self.id = id
        self.location = location
        self.caption = caption
        self.isImage = isImage
        self.postURL = postURL
        self.thumbnailURL = thumbnailURL
        self.time = time
        self.dimensions = dimensions
    }
    
    func getid() -> String {
        return id
    }
    func getTime() -> NSDate {
        return time
    }
    
    //quicksort based on timestamp
    static func < (lhs: PortfolioPost, rhs: PortfolioPost) -> Bool {
        //inverse so that quick sort of feed shows most recent first
        return rhs.getTime().compare(lhs.getTime() as Date) == .orderedAscending
    }
    
    static func == (lhs: PortfolioPost, rhs: PortfolioPost) -> Bool {
        return lhs.getTime() == rhs.getTime() || lhs.getTime().compare(rhs.getTime() as Date) == .orderedSame
    }
}

