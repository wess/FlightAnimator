//
//  CGSize+FAAnimatable.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public func ==(lhs:CGSize, rhs:CGSize) -> Bool {
    return  lhs.equalTo(rhs)
}

extension CGSize : FAAnimatable {
    
    public typealias T = CGSize
    
    public func magnitudeValue() -> CGFloat {
        return sqrt((width * width) + (height * height))
    }
    
    public func magnitudeToValue<T : FAAnimatable>(_ toValue:  T) -> CGFloat {
        return CGSize(width: (toValue as! CGSize).width - width, height: (toValue as! CGSize).height - height).magnitudeValue()
    }
    
    public func interpolatedValue<T : FAAnimatable>(_ toValue : T, progress : CGFloat) -> AnyObject {
        let width : CGFloat = ceil(interpolateCGFloat(self.width, end: (toValue as! CGSize).width, progress: progress))
        let height : CGFloat = ceil(interpolateCGFloat(self.height, end: (toValue as! CGSize).height, progress: progress))
        return  CGSize(width: width, height: height).valueRepresentation()
    }
    
    public func interpolatedSpringValue<T : FAAnimatable>(_ toValue : T, springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> AnyObject {
        let size = CGSize(width: springs[SpringAnimationKey.CGSizeWidth]!.updatedValue(deltaTime),
                              height: springs[SpringAnimationKey.CGSizeHeight]!.updatedValue(deltaTime))
        return size.valueRepresentation()
    }
    
    public func springVelocity(_ springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> CGPoint {
        if let currentWidthVelocity = springs[SpringAnimationKey.CGSizeWidth]?.velocity(deltaTime),
            let currentHeightVelocity = springs[SpringAnimationKey.CGSizeHeight]?.velocity(deltaTime) {
                return  CGPoint(x: currentWidthVelocity, y: currentHeightVelocity)
        }
        
        return CGPoint.zero
    }
    
    public func interpolationSprings<T : FAAnimatable>(_ toValue : T, initialVelocity : Any, angularFrequency : CGFloat, dampingRatio : CGFloat) -> Dictionary<String, FASpring> {
        
        var springs = Dictionary<String, FASpring>()
    
        if let startingVelocity = initialVelocity as? CGPoint {
            let widthSpring = self.width.interpolationSprings((toValue as! CGSize).width, initialVelocity : startingVelocity.x, angularFrequency : angularFrequency, dampingRatio : dampingRatio)
            let heightSpring = self.height.interpolationSprings((toValue as! CGSize).height, initialVelocity : startingVelocity.y, angularFrequency : angularFrequency, dampingRatio : dampingRatio)
            
            springs[SpringAnimationKey.CGSizeWidth]  = widthSpring[SpringAnimationKey.CGFloat]
            springs[SpringAnimationKey.CGSizeHeight] = heightSpring[SpringAnimationKey.CGFloat]
        }
        
        return springs
    }
    
    public func valueRepresentation() -> AnyObject {
        return NSValue(cgSize :  self)
    }
}
