//
//  CGRect+FAAnimatable.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public func ==(lhs:CGRect, rhs:CGRect) -> Bool {
    return lhs.equalTo(rhs)
}

extension CGRect : FAAnimatable {
    
    public typealias T = CGRect
    
    public func magnitudeValue() -> CGFloat {
        return sqrt((width * width) + (height * height))
    }
    
    public func magnitudeToValue<T : FAAnimatable>(_ toValue:  T) -> CGFloat {
        return CGSize(width: (toValue as! CGRect).width - width, height: (toValue as! CGRect).height - height).magnitudeValue()
    }
    
    public func interpolatedValue<T : FAAnimatable>(_ toValue : T, progress : CGFloat) -> AnyObject {
        let width : CGFloat = ceil(interpolateCGFloat(self.width, end: (toValue as! CGRect).width, progress: progress))
        let height : CGFloat = ceil(interpolateCGFloat(self.height, end: (toValue as! CGRect).height, progress: progress))
        return CGRect(x: 0, y: 0, width: width, height: height).valueRepresentation()
    }
    
    public func interpolatedSpringValue<T : FAAnimatable>(_ toValue : T, springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> AnyObject {
        let rect = CGRect(x: 0,
                              y: 0,
                              width: springs[SpringAnimationKey.CGSizeWidth]!.updatedValue(deltaTime),
                              height: springs[SpringAnimationKey.CGSizeHeight]!.updatedValue(deltaTime))
        
        return rect.valueRepresentation()
    }
    
    
    public func springVelocity(_ springs : Dictionary<String, FASpring>, deltaTime : CGFloat) -> CGPoint {
        if let currentXVelocity = springs[SpringAnimationKey.CGPointX]?.velocity(deltaTime),
            let currentYVelocity = springs[SpringAnimationKey.CGPointY]?.velocity(deltaTime) {
            return  CGPoint(x: currentXVelocity, y: currentYVelocity)
        }
        
        return CGPoint.zero
    }
    
    public func interpolationSprings<T : FAAnimatable>(_ toValue : T, initialVelocity : Any, angularFrequency : CGFloat, dampingRatio : CGFloat) -> Dictionary<String, FASpring> {
        var springs = Dictionary<String, FASpring>()
        
        if let startingVelocity = initialVelocity as? CGPoint {
            
            let sizeSprings = (toValue as! CGRect).size.interpolationSprings((toValue as! CGRect).size,
                                                                             initialVelocity : startingVelocity,
                                                                             angularFrequency : angularFrequency,
                                                                             dampingRatio : dampingRatio)
            
            let origin = (toValue as! CGRect).origin
            
            let positionSprings = origin.interpolationSprings(origin,
                                                              initialVelocity : startingVelocity,
                                                              angularFrequency : angularFrequency,
                                                              dampingRatio : dampingRatio)
            
            springs[SpringAnimationKey.CGSizeWidth]   = sizeSprings[SpringAnimationKey.CGSizeWidth]
            springs[SpringAnimationKey.CGSizeHeight]  = sizeSprings[SpringAnimationKey.CGSizeHeight]
            springs[SpringAnimationKey.CGPointX]      = positionSprings[SpringAnimationKey.CGPointX]
            springs[SpringAnimationKey.CGPointY]      = positionSprings[SpringAnimationKey.CGPointY]
        }
        return springs
    }
    
    public func valueRepresentation() -> AnyObject {
        return NSValue(cgRect :  self)
    }
}
