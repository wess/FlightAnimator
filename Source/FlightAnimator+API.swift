//
//  UIView+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {
    
    func animate(@noescape animator : (sequenceAnimator : FlightAnimator) -> Void) {
        
        let animationKey = NSUUID().UUIDString
        
        let newAnimator = FlightAnimator(withView: self, forKey : animationKey)
        animator(sequenceAnimator : newAnimator)
        newAnimator.startSequence()
    }
    
    func cacheAnimation(forKey key: String,
                        timingPriority : FAPrimaryTimingPriority = .MaxTime,
                        @noescape animator : (animator : FlightAnimator) -> Void ) {
        
        let newAnimator = FlightAnimator(withView: self, forKey : key)
        animator(animator : newAnimator)
        newAnimator.sequence.synchronizeRootSequenceTriggers()
        cacheAnimation(newAnimator.sequence, forKey: key)
    }
}

// MARK: - Sequence Configuration

public extension FlightAnimator  {
 
    public func autoreverse(autoreverse : Bool) -> GroupAnimationConfig {
        sequence.autoreverse = autoreverse
        return groupConfigurations[animationKey!]!
    }
    
    public func autoreverseCount(autoreverseCount : Int) -> GroupAnimationConfig {
        sequence.autoreverseCount = autoreverseCount
        return groupConfigurations[animationKey!]!
    }
    
    public func autoreverseDelay(autoreverseDelay : NSTimeInterval) -> GroupAnimationConfig {
        sequence.autoreverseDelay = autoreverseDelay
        return groupConfigurations[animationKey!]!
    }

    public func autoreverseInvertEasing(autoreverseInvertEasing : Bool) -> GroupAnimationConfig {
        sequence.autoreverseInvertEasing = autoreverseInvertEasing
        return groupConfigurations[animationKey!]!
    }

    public func autoreverseInvertProgress(autoreverseInvertProgress: Bool) -> GroupAnimationConfig {
        sequence.autoreverseInvertProgress = autoreverseInvertProgress
        return groupConfigurations[animationKey!]!
    }
}

// MARK: - Group Animation Configuration

public extension FlightAnimator  {
   
    public func timingPriority(timingPriority : FAPrimaryTimingPriority) -> GroupAnimationConfig {
        groupConfigurations[animationKey!]!.animationGroup.timingPriority = timingPriority
        return groupConfigurations[animationKey!]!
    }
}

// MARK: - Property Animation Configuration

public extension FlightAnimator  {
    
    public func alpha(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "opacity")
    }
    
    public func anchorPoint(value : CGPoint) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "anchorPoint")
    }
    
    public func backgroundColor(value : CGColor) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "backgroundColor")
    }
    
    public func bounds(value : CGRect) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "bounds")
    }
    
    public func borderColor(value : CGColor) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "borderColor")
    }
    
    public func borderWidth(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "borderWidth")
    }
    
    public func contentsRect(value : CGRect) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "contentsRect")
    }
    
    public func cornerRadius(value : CGPoint) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "cornerRadius")
    }
    
    public func opacity(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "opacity")
    }
    
    public func position(value : CGPoint) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "position")
    }
    
    public func shadowColor(value : CGColor) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowColor")
    }
    
    public func shadowOffset(value : CGSize) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowOffset")
    }
    
    public func shadowOpacity(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowOpacity")
    }
    
    public func shadowRadius(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowRadius")
    }
    
    public func size(value : CGSize) -> PropertyAnimationConfig {
        return bounds(CGRectMake(0, 0, value.width, value.height))
    }
    
    public func sublayerTransform(value : CATransform3D) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "sublayerTransform")
    }
    
    public func transform(value : CATransform3D) -> PropertyAnimationConfig{
        return self.value(value, forKeyPath : "transform")
    }
    
    public func animateZPosition(value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "animateZPosition")
    }
    
    public func value(value : Any, forKeyPath key : String) -> PropertyAnimationConfig {
        
        if let value = value as? UIColor {
            groupConfigurations[animationKey!]?.animationConfigurations[key] = PropertyAnimationConfig(value: value.CGColor, forKeyPath: key, view : self.associatedView!)
        } else {
            groupConfigurations[animationKey!]?.animationConfigurations[key] = PropertyAnimationConfig(value: value,
                                                                                                       forKeyPath: key,
                                                                                                       view : self.associatedView!)
        }
        
        return (groupConfigurations[animationKey!]?.animationConfigurations[key])!
    }
}

// MARK: - Sequence Trigger Configuration

public extension FlightAnimator {
    
    public func triggerOnStart(timingPriority : FAPrimaryTimingPriority = .MaxTime,
                               onView view: UIView,
                               @noescape animator: (animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : true, view: view, progress: 0.0, animator: animator)
    }
    
    public func triggerOnProgress(progress : CGFloat,
                                  onView view: UIView ,
                                  timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                  @noescape animator: (animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : true, view: view, progress: progress, animator: animator)
    }
    
    public func triggerOnValueProgress(progress : CGFloat,
                                  onView view: UIView ,
                                         timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                         @noescape animator: (animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : false, view: view, progress: progress, animator: animator)
    }
    
    public func triggerOnCompletion(timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                    onView view: UIView,
                                    @noescape animator: (animator : FlightAnimator) -> Void) {
        
        triggerAnimation(timingPriority, timeBased : true, view: view, progress: 1.0, animator: animator)
    }
}

// MARK: - Animation Delegate Configuration

extension FlightAnimator {
    
    public func setDidStopCallback(stopCallback : FAAnimationDidStop) {
        groupConfigurations[animationKey!]!.animationGroup.setDidStopCallback(stopCallback)
    }
    
    public func setDidStartCallback(startCallback : FAAnimationDidStart) {
        groupConfigurations[animationKey!]!.animationGroup.setDidStartCallback(startCallback)
    }
}
