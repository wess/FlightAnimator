//
//  FlightAnimate+Private.swift
//  
//
//  Created by Anton on 6/29/16.
//
//

import Foundation
import UIKit

public class FAAnimationMaker {
    
    internal weak var associatedView : UIView?
    internal var animationKey : String?
    
    var animationConfigurations = [String : PropertyAnimationConfig]()
    var primaryTimingPriority : FAPrimaryTimingPriority = .maxTime
    
    init(withView view : UIView, forKey key: String, priority : FAPrimaryTimingPriority = .maxTime) {
        animationKey = key
        associatedView = view
        primaryTimingPriority = priority
        configureNewGroup()
    }
    
    private func configureNewGroup() {
        
        if associatedView!.cachedAnimations == nil {
            associatedView!.cachedAnimations = [String : FAAnimationGroup]()
        }
        
        let newGroup = FAAnimationGroup()
        newGroup.animationKey = animationKey
        newGroup.weakLayer = associatedView?.layer
        newGroup.primaryTimingPriority = primaryTimingPriority
        
        associatedView!.cachedAnimations![animationKey!] = newGroup
    }
    
    internal func triggerAnimation(_ timingPriority : FAPrimaryTimingPriority = .maxTime,
                                   timeBased : Bool,
                                   key: String,
                                   view: UIView,
                                   progress: CGFloat = 0.0,
                                   animator: @noescape(animator : FlightAnimator) -> Void) {

        if let animationGroup = associatedView!.cachedAnimations![animationKey!] {
            
            animationGroup._segmentArray.append(AnimationTrigger(isTimedBased: timeBased,
                                                            triggerProgessValue: progress,
                                                            animationKey: animationKey!,
                                                            animatedView: view))

            associatedView!.attachAnimation(animationGroup, forKey: animationKey!)
        }
        
        let newAnimator = FlightAnimator(withView: view, forKey : animationKey!, priority : timingPriority)
        animator(animator : newAnimator)
    }
}

public protocol PropertyAnimationConfig {
    var easingCurve : FAEasing { get }
    var duration : CGFloat { get }
    
    @discardableResult func duration(_ duration : CGFloat) -> PropertyAnimationConfig
    @discardableResult func easing(_ easing : FAEasing) -> PropertyAnimationConfig
    @discardableResult func primary(_ primary : Bool) -> PropertyAnimationConfig
}

private class Configuration {
    var value: PropertyAnimationConfig
    
    init<T : FAAnimatable>(value: T, forKeyPath key : String, view : UIView, animationKey : String) {
        self.value = ConfigurationValue(value: value, forKeyPath : key, view : view, animationKey : animationKey)
    }
}

internal class ConfigurationValue<T : FAAnimatable> : PropertyAnimationConfig {
    
    private weak var associatedView : UIView?
    private var animationKey : String?
    private var keyPath : String?
    
    var toValue : T
    var easingCurve : FAEasing = .linear
    var duration : CGFloat
    var primary : Bool
    
    init(value: T, forKeyPath key : String, view : UIView, animationKey : String) {
        self.animationKey = animationKey
        self.associatedView = view
        self.keyPath = key
        self.toValue = value
        self.easingCurve = .linear
        self.duration = 0.0
        self.primary = false
    }
    
    @discardableResult func duration(_ duration : CGFloat) -> PropertyAnimationConfig {
        self.duration = duration
        updateAnimation()
        return self
    }
    
    @discardableResult func easing(_ easing : FAEasing) -> PropertyAnimationConfig {
        self.easingCurve = easing
        updateAnimation()
        return self
    }
    
    @discardableResult func primary(_ primary : Bool) -> PropertyAnimationConfig {
        self.primary = primary
        updateAnimation()
        return self
    }
    
    private func updateAnimation() {
        guard let animationGroup = associatedView!.cachedAnimations![animationKey!] else {
            return
        }
        
        let animation = FAAnimation(keyPath: keyPath)
        animation.easingFunction = easingCurve
        animation.toValue = toValue.valueRepresentation()
        animation.duration = Double(duration)
        animation.setAnimationAsPrimary(primary)
        
        animationGroup.weakLayer = associatedView?.layer
        animationGroup.animations!.append(animation)
        
        associatedView!.cachedAnimations![animationKey!] = animationGroup
    }
}
