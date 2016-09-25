//
//  CustomConfigurationView.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 9/15/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
import CoreFlightAnimation
import FlightAnimator

class CustomConfigurationView : UIView {
    
    var interactionDelegate: ConfigurationViewDelegate?
    weak var cellDelegate : CurveCollectionViewCellDelegate?
    
    var selectedIndex: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    var initialCenter = CGPointZero
    var adjustedPosition = CGPointZero
    var lastSelectedDelaySegment : Int = 0
    
    var propertyConfigType : PropertyConfigType = PropertyConfigType.Bounds {
        didSet {
            self.contentCollectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        registerCells()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    func setup() {
        clipsToBounds = true
        backgroundColor = UIColor(rgba: "#444444")

        addSubview(contentCollectionView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentCollectionView.alignWithSize(CGSizeMake(self.bounds.width, 336),
                                            toFrame: self.bounds,
                                            horizontal: HGHorizontalAlign.Center,
                                            vertical: HGVerticalAlign.Below,
                                            verticalOffset : 0)
        

    }
    
    func registerCells() {
        contentCollectionView.registerClass(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell0")
        contentCollectionView.registerClass(CurveSelectionCollectionViewCell.self, forCellWithReuseIdentifier: "PropertyCell1")
    }
    
    // MARK: - Lazy Loaded Views
    
    lazy var contentCollectionView : UICollectionView = {
        [unowned self] in
        
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 1.0
        flowLayout.minimumLineSpacing = 1.0
        flowLayout.scrollDirection = .Vertical
        flowLayout.sectionInset = UIEdgeInsetsZero
        
        var tempCollectionView : UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout :flowLayout)
        tempCollectionView.alpha = 1.0
        tempCollectionView.clipsToBounds = true
        tempCollectionView.backgroundColor = UIColor.whiteColor()
        tempCollectionView.delegate = self
        tempCollectionView.dataSource = self
        tempCollectionView.scrollEnabled = false
        tempCollectionView.pagingEnabled = false
        return tempCollectionView
        }()
}

extension CustomConfigurationView : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout, sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width, 84)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) { }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return cellAtIndex(indexPath)
    }
    
    func cellAtIndex(indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = contentCollectionView.dequeueReusableCellWithReuseIdentifier("PropertyCell\(indexPath.row)" as String, forIndexPath: indexPath) as? CurveSelectionCollectionViewCell {
            cell.delegate = cellDelegate
            cell.propertyConfigType = PropertyConfigType(rawValue : indexPath.row)!
            cell.primarySwitch.on = interactionDelegate!.currentPrimaryFlagValue(indexPath.row)
            cell.pickerView.selectRow(functions.indexOf(interactionDelegate!.currentEAsingFuntion(indexPath.row))!, inComponent: 0, animated: true)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

