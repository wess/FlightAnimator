//
//  UIView+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

/**
 The timing priority effect how the time is resynchronized across the animation group.
 If the FAAnimation is marked as primary
 
 - MaxTime: <#MaxTime description#>
 - MinTime: <#MinTime description#>
 - Median:  <#Median description#>
 - Average: <#Average description#>
 */
public enum FAPrimaryTimingPriority : Int {
    case maxTime
    case minTime
    case median
    case average
}

public func registerAnimation(onView view : UIView,
                              forKey key: String,
                              timingPriority : FAPrimaryTimingPriority = .maxTime,
                              animator : @noescape(animator : FlightAnimator) -> Void ) {
    
    let newAnimator = FlightAnimator(withView: view, forKey : key, priority : timingPriority)
    animator(animator : newAnimator)
}

public extension UIView {
    
    func animate(_ timingPriority : FAPrimaryTimingPriority = .maxTime, animator : @noescape(animator : FlightAnimator) -> Void ) {
        let newAnimator = FlightAnimator(withView: self, forKey : "AppliedAnimation",  priority : timingPriority)
        animator(animator : newAnimator)
        applyAnimation(forKey: "AppliedAnimation")
    }

    func applyAnimation(forKey key: String,
                        animated : Bool = true) {
        
        if let cachedAnimationsArray = self.cachedAnimations,
            let animation = cachedAnimationsArray[key] {
            animation.applyFinalState(animated)
        }
    }
    
    func applyAnimationTree(forKey key: String,
                            animated : Bool = true) {
        
        applyAnimation(forKey : key, animated:  animated)
        applyAnimationsToSubViews(self, forKey: key, animated: animated)
    }
}

public class FlightAnimator : FAAnimationMaker {
    
    public func setDidStopCallback(_ stopCallback : FAAnimationDidStop) {
        if ((associatedView?.cachedAnimations?.keys.contains(animationKey!)) != nil) {
             associatedView!.cachedAnimations![animationKey!]!.setDidStopCallback(stopCallback)
        }
    }
    
    public func setDidStartCallback(_ startCallback : FAAnimationDidStart) {
        if ((associatedView?.cachedAnimations?.keys.contains(animationKey!)) != nil) {
            associatedView!.cachedAnimations![animationKey!]!.setDidStartCallback(startCallback)
        }
    }
    
    public func triggerOnStart(_ timingPriority : FAPrimaryTimingPriority = .maxTime,
                               onView view: UIView,
                               animator: @noescape(animator : FlightAnimator) -> Void) {
        triggerAnimation(timingPriority, timeBased : true, key: animationKey!, view: view, progress: 0.0, animator: animator)
    }
    
    public func triggerAtTimeProgress(_ timingPriority : FAPrimaryTimingPriority = .maxTime,
                                      atProgress progress: CGFloat,
                                      onView view: UIView,
                                      animator: @noescape(animator : FlightAnimator) -> Void) {
        triggerAnimation(timingPriority, timeBased : true, key: animationKey!, view: view, progress: progress, animator: animator)
    }
    
    @discardableResult public func triggerAtValueProgress(_ timingPriority : FAPrimaryTimingPriority = .maxTime,
                                       atProgress progress: CGFloat,
                                       onView view: UIView,
                                       animator: @noescape(animator : FlightAnimator) -> Void) {
        triggerAnimation(timingPriority, timeBased : false, key: animationKey!, view: view, progress: progress, animator: animator)
    }
    
    
    @discardableResult  public func value<T : FAAnimatable>(_ value : T, forKeyPath key : String) -> PropertyAnimationConfig {
        
        if let value = value as? UIColor {
            animationConfigurations[key] = ConfigurationValue(value: value.cgColor, forKeyPath: key, view : associatedView!, animationKey: animationKey!)
        } else {
            animationConfigurations[key] = ConfigurationValue(value: value, forKeyPath: key, view : associatedView!, animationKey: animationKey!)
        }
    
        return animationConfigurations[key]!
    }
    
    @discardableResult public func alpha(_ value : CGFloat) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "opacity")
    }
    
    @discardableResult public func anchorPoint<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "anchorPoint")
    }
    
    @discardableResult public func backgroundColor<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "backgroundColor")
    }
    
    @discardableResult public func bounds<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "bounds")
    }
    
    @discardableResult public func borderColor<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "borderColor")
    }
    
    @discardableResult public func borderWidth<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "borderWidth")
    }

    @discardableResult public func contentsRect<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig{
        return self.value(value, forKeyPath : "contentsRect")
    }
    
    @discardableResult public func cornerRadius<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "cornerRadius")
    }
    
    @discardableResult public func opacity<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "opacity")
    }
    
    @discardableResult public func position<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "position")
    }
    
    @discardableResult public func shadowColor<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowColor")
    }
    
    @discardableResult public func shadowOffset<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowOffset")
    }
    
    @discardableResult  public func shadowOpacity<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowOpacity")
    }
    
    @discardableResult public func shadowRadius<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "shadowRadius")
    }
    
    @discardableResult public func size<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return bounds(CGRect(x: 0, y: 0, width: (value as? CGSize)!.width, height: (value as? CGSize)!.height))
    }
    
    @discardableResult public func sublayerTransform<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "sublayerTransform")
    }
    
    @discardableResult public func transform<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig{
        return self.value(value, forKeyPath : "transform")
    }
    
    @discardableResult public func animateZPosition<T : FAAnimatable>(_ value : T) -> PropertyAnimationConfig {
        return self.value(value, forKeyPath : "animateZPosition")
    }
}

