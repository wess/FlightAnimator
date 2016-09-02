//
//  UIView+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
import CoreFlightAnimation

internal let AutoAnimationKey =  "AutoAnimationKey"

public extension UIView {
    
    func animate(timingPriority : FAPrimaryTimingPriority = .MaxTime,
                 @noescape animator : (a : FlightAnimator) -> Void ) {
        
        let animationKey = String(NSUUID().UUIDString)

        let newAnimator = FlightAnimator(withView: self, forKey : animationKey,  priority : timingPriority, sequenceKey : animationKey)
        animator(a : newAnimator)
    
        cachedSequences[animationKey]?.startSequence()
    }
    
    func cacheAnimation(forKey key: String,
                        timingPriority : FAPrimaryTimingPriority = .MaxTime,
                        @noescape animator : (a : FlightAnimator) -> Void ) {
        
        let triggerAnimation = FAAnimationGroup()
        triggerAnimation.weakLayer = layer
        triggerAnimation.animationKey = key
        
        let newAnimator = FlightAnimator(withView: self, forKey : key, priority : timingPriority, sequenceKey : key)
        animator(a : newAnimator)
    }
}

public class FlightAnimator : FlightAnimationMaker {
    
    public func value(value : Any, forKeyPath key : String) -> PropertyAnimator {
        
        if let value = value as? UIColor {
            animationConfigurations[key] = PropertyAnimator(value: value.CGColor,
                                                                   forKeyPath: key,
                                                                   view : associatedView!,
                                                                   animationKey: animationKey!,
                                                                   sequenceKey: sequenceKey!)
        } else {
            animationConfigurations[key] = PropertyAnimator(value: value,
                                                                   forKeyPath: key,
                                                                   view : associatedView!,
                                                                   animationKey: animationKey!,
                                                                   sequenceKey: sequenceKey!)
        }
        
        return animationConfigurations[key]!
    }
    
    public func alpha(value : CGFloat) -> PropertyAnimator {
        return self.value(value, forKeyPath : "opacity")
    }
    
    public func anchorPoint(value : CGPoint) -> PropertyAnimator {
        return self.value(value, forKeyPath : "anchorPoint")
    }
    
    public func backgroundColor(value : CGColor) -> PropertyAnimator {
        return self.value(value, forKeyPath : "backgroundColor")
    }
    
    public func bounds(value : CGRect) -> PropertyAnimator {
        return self.value(value, forKeyPath : "bounds")
    }

    public func borderColor(value : CGColor) -> PropertyAnimator {
        return self.value(value, forKeyPath : "borderColor")
    }
    
    public func borderWidth(value : CGFloat) -> PropertyAnimator {
        return self.value(value, forKeyPath : "borderWidth")
    }

    public func contentsRect(value : CGRect) -> PropertyAnimator {
        return self.value(value, forKeyPath : "contentsRect")
    }
    
    public func cornerRadius(value : CGPoint) -> PropertyAnimator {
        return self.value(value, forKeyPath : "cornerRadius")
    }
    
    public func opacity(value : CGFloat) -> PropertyAnimator {
        return self.value(value, forKeyPath : "opacity")
    }
    
    public func position(value : CGPoint) -> PropertyAnimator {
        return self.value(value, forKeyPath : "position")
    }
    
    public func shadowColor(value : CGColor) -> PropertyAnimator {
        return self.value(value, forKeyPath : "shadowColor")
    }
    
    public func shadowOffset(value : CGSize) -> PropertyAnimator {
        return self.value(value, forKeyPath : "shadowOffset")
    }
    
    public func shadowOpacity(value : CGFloat) -> PropertyAnimator {
        return self.value(value, forKeyPath : "shadowOpacity")
    }
    
    public func shadowRadius(value : CGFloat) -> PropertyAnimator {
        return self.value(value, forKeyPath : "shadowRadius")
    }
    
    public func size(value : CGSize) -> PropertyAnimator {
        return self.bounds(CGRectMake(0, 0, value.width, value.height))
    }
    
    public func sublayerTransform(value : CATransform3D) -> PropertyAnimator {
        return self.value(value, forKeyPath : "sublayerTransform")
    }
    
    public func transform(value : CATransform3D) -> PropertyAnimator{
        return self.value(value, forKeyPath : "transform")
    }
    
    public func zPosition(value : CGFloat) -> PropertyAnimator {
        return self.value(value, forKeyPath : "zPosition")
    }
}

extension FlightAnimator {
    
    public func triggerOnStart(onView view: UIView,
                              timingPriority : FAPrimaryTimingPriority = .MaxTime,
                              @noescape animator: (animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : true, view: view, progress: 0.0, animator: animator)
    }

    public func triggerOnCompletion(onView view: UIView,
                                    timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                    @noescape animator: (animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : true, view: view, progress: 1.0, animator: animator)
    }
    
    public func triggerOnProgress(progress: CGFloat,
                                  onView view: UIView,
                                  timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                  @noescape animator: (animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : true, view: view, progress: progress, animator: animator)
    }
    
    public func triggerOnValueProgress(progress: CGFloat,
                                       onView view: UIView,
                                       timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                       @noescape animator: (animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : false, view: view, progress: progress, animator: animator)
    }
}

extension FlightAnimator {
    
    public func setDidStopCallback(stopCallback : FAAnimationDidStop) {
        if cachedSequences.keys.contains(sequenceKey!) {
            cachedSequences[sequenceKey!]?._sequenceTriggers[animationKey!]!.triggeredAnimation?.setDidStopCallback(stopCallback)
        }
    }
    
    public func setDidStartCallback(startCallback : FAAnimationDidStart) {
        if cachedSequences.keys.contains(sequenceKey!) {
            cachedSequences[sequenceKey!]?._sequenceTriggers[animationKey!]!.triggeredAnimation?.setDidStartCallback(startCallback)
        }
    }
}
