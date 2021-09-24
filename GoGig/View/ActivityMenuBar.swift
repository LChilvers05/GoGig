//
//  ActivityMenuBar.swift
//  GoGig
//
//  Created by Lee Chilvers on 23/07/2019.
//  Copyright © 2019 ChillyDesigns. All rights reserved.
//

import UIKit

class MenuBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var activityFeedVC: ActivityFeedVC?
    
    let cellID = "menuBarCell"
    let titleNames = ["Notifications", "My Events"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //collection view is the titles
        setupCollectionView()
        //horizontal bar is the purple slider
        setupHorizontalBar()
        //to keep track of what cell is selected
        let selectedIndexPath = NSIndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath as IndexPath, animated: false, scrollPosition: .left)
    }
    
    //when user taps that one, then take to another table view
    //this moves the large collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        activityFeedVC?.scrollToMenuIndex(menuIndex: indexPath.item)
    }
    
    
    //MARK: SETUP
    
    //UI with swift closures
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //this changes to create animation
    var barLeftAnchorConstraint: NSLayoutConstraint?
    
    func setupHorizontalBar() {
        let barView = UIView()
        barView.backgroundColor = .purple
        barView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(barView)
        
        barView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        barView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        //multiplier 0.5 so takes half of device view
        barView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5).isActive = true
        
        barLeftAnchorConstraint = barView.leftAnchor.constraint(equalTo: self.leftAnchor)
        barLeftAnchorConstraint?.isActive = true
    }
    
    
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        addSubview(separator)
        separator.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        separator.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        separator.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    //MAKR: MENU BAR COLLECTION VIEW
    
    //two titles needed
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    //set appearance of each menubar cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MenuCell
        
        cell.title.text = titleNames[indexPath.item]
        
        return cell
    }
    //set size of cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: frame.width / 2, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: MENU CELL

class MenuCell: UICollectionViewCell {
    
    //add the title
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addTitle()
    }
    //set appearance of titles
    let title: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.font = UIFont(name: "Avenir-Medium", size: 20.0)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    //becomes purple when active...
    override var isHighlighted: Bool {
        didSet {
            title.textColor = isHighlighted ? UIColor.purple : UIColor.lightGray
        }
    }
    
    //...and selected
    override var isSelected: Bool {
        didSet {
            title.textColor = isSelected ? UIColor.purple : UIColor.lightGray
        }
    }
    //add the title to the cell
    func addTitle() {
        addSubview(title)
        title.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        title.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        title.heightAnchor.constraint(equalToConstant: 28).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
