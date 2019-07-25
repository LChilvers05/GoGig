//
//  ActivityFeedCollectionView.swift
//  GoGig
//
//  Created by Lee Chilvers on 23/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

extension ActivityFeedVC {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cvCell", for: indexPath) as! ActivityCVCell
        
        let colors: [UIColor] = [.red, .blue]
        
        cell.feedTableView.reloadData()
        
        cell.backgroundColor = colors[indexPath.item]
        
        return cell
    }
    
}
