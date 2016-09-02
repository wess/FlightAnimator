//
//  FlightAnimate+Private.swift
//  
//
//  Created by Anton on 6/29/16.
//
//

import Foundation
import UIKit

public class FlightAnimationMaker {
    
    internal var sequenceKey : String?
    
    internal weak var associatedView : UIView?
    internal var animationKey : String?
    internal var triggerProgress: CGFloat = 0.0
    
    var animationConfigurations = [String : PropertyAnimator]()
    var primaryTimingPriority : FAPrimaryTimingPriority = .MaxTime
    
    public init(withView view : UIView, forKey key: String, priority : FAPrimaryTimingPriority = .MaxTime, progress: CGFloat = 0.0, sequenceKey seqkey : String?) {
        animationKey = key
        associatedView = view
        triggerProgress =  progress
        sequenceKey = seqkey
        primaryTimingPriority = priority
        configureNewGroup()
    }
    
    private func configureNewGroup() {
        let newGroup = FAAnimationGroup()
        newGroup.configureAnimationGroup(withLayer: associatedView?.layer, animationKey: animationKey)
        newGroup.timingPriority = primaryTimingPriority
        newGroup.animationKey = animationKey
        
        if let sequence = cachedSequences[sequenceKey!] {
            sequence.addSequenceFrame(withAnimation: newGroup, onView: associatedView!, atProgress: triggerProgress)
        } else {
            let sequence = FASequence(onView: associatedView!, withAnimation: newGroup)
            cachedSequences[sequenceKey!] = sequence
        }
    }
    
    internal func triggerAnimation(timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                   timeBased : Bool,
                                   view: UIView,
                                   progress: CGFloat = 0.0,
                                   @noescape animator: (animator : FlightAnimator) -> Void) {

        let frameKey = String(NSUUID().UUIDString)
        
        let newAnimator = FlightAnimator(withView: view, forKey : frameKey,  priority : timingPriority, progress : progress, sequenceKey : sequenceKey)
        animator(animator : newAnimator)
    }
}

public class PropertyAnimator  {
    
    internal var sequenceKey : String?
    private var animationKey : String?
    
    private weak var associatedView : UIView?
    private var keyPath : String?
    
    var toValue : Any
    var easingCurve : FAEasing = .Linear
    var duration : CGFloat
    var primary : Bool
    
    init(value: Any, forKeyPath key : String, view : UIView, animationKey animKey: String, sequenceKey seqKey : String) {
        animationKey = animKey
        sequenceKey = seqKey
        associatedView = view
        keyPath = key
        toValue = value
        easingCurve = .Linear
        duration = 0.0
        primary = false
    }
    
    public func duration(duration : CGFloat) -> PropertyAnimator {
        self.duration = duration
        updateAnimation()
        return self
    }
    
    public func easing(easing : FAEasing) -> PropertyAnimator {
        self.easingCurve = easing
        updateAnimation()
        return self
    }
    
    public func primary(primary : Bool) -> PropertyAnimator {
        self.primary = primary
        updateAnimation()
        return self
    }
    
    private func updateAnimation() {
        guard let sequenceTrigger = cachedSequences[sequenceKey!]?._sequenceTriggers[animationKey!] else {
            return
        }
        
        if let animations = sequenceTrigger.triggeredAnimation?.animations {
            
            let filteredAnimations = (animations as! [FABasicAnimation]).filter ({ $0.keyPath == self.keyPath }).first
            
            if let animation = filteredAnimations {
                
                if let currentValue = toValue as? CGPoint {
                    animation.toValue =  NSValue(CGPoint :currentValue)
                } else  if let currentValue = toValue as? CGSize {
                    animation.toValue = NSValue( CGSize :currentValue)
                } else  if let currentValue = toValue as? CGRect {
                    animation.toValue = NSValue( CGRect : currentValue)
                } else  if let currentValue = toValue as? CGFloat {
                    animation.toValue = currentValue
                } else  if let currentValue = toValue as? CATransform3D {
                    animation.toValue =  NSValue( CATransform3D : currentValue)
                } else if let currentValue = typeCastCGColor(toValue) {
                    animation.toValue = currentValue
                }
                
                animation.duration = Double(duration)
                animation.isPrimary = primary
                animation.easingFunction = easingCurve
                
                sequenceTrigger.triggeredAnimation?.configureAnimationGroup(withLayer: associatedView?.layer, animationKey: animationKey)
                sequenceTrigger.triggeredAnimation?.animations!.append(animation)
                
                cachedSequences[sequenceKey!]?._sequenceTriggers[animationKey!] = sequenceTrigger
                return
            }
        }
        
        let animation = FABasicAnimation(keyPath: keyPath)
        animation.easingFunction = easingCurve
       
        if let currentValue = toValue as? CGPoint {
            animation.toValue =  NSValue(CGPoint :currentValue)
        } else  if let currentValue = toValue as? CGSize {
            animation.toValue = NSValue( CGSize :currentValue)
        } else  if let currentValue = toValue as? CGRect {
            animation.toValue = NSValue( CGRect : currentValue)
        } else  if let currentValue = toValue as? CGFloat {
            animation.toValue = currentValue
        } else  if let currentValue = toValue as? CATransform3D {
            animation.toValue =  NSValue( CATransform3D : currentValue)
        } else if let currentValue = typeCastCGColor(toValue) {
            animation.toValue = currentValue
        }
        
        animation.duration = Double(duration)
        animation.isPrimary = primary
        
        sequenceTrigger.triggeredAnimation?.configureAnimationGroup(withLayer: associatedView?.layer, animationKey: animationKey)
        sequenceTrigger.triggeredAnimation?.animations!.append(animation)
       
        cachedSequences[sequenceKey!]?._sequenceTriggers[animationKey!] = sequenceTrigger
    }
}






