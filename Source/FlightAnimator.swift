//
//  FlightAnimate+Private.swift
//  
//
//  Created by Anton on 6/29/16.
//
//

import Foundation
import UIKit
import CoreFlightAnimation

public class FlightAnimator {
    
    internal weak var associatedView : UIView?
    internal var animationKey : String?
   
    internal var sequence : FASequence = FASequence()
    
    public var groupConfigurations = [String : GroupAnimationConfig]()

    init(withView view : UIView, forKey key: String) {
        animationKey = key
        associatedView = view
        configuredNewSequence()
    }
    /*
    private func animationGroup() -> FAAnimationGroup? {
        for (_, groupConfig) in groupConfigurations {
            for (_, propConfig) in groupConfig.animationConfigurations {
                groupConfig.animationGroup.animations?.append(propConfig.propertyAnimation)
            }
            
            return groupConfig.animationGroup
        }
        return nil
    }
    */
    private func configuredNewSequence() {
        groupConfigurations[animationKey!] = GroupAnimationConfig(view: associatedView!, animationKey: animationKey!)
    }
    
    public func startSequence() {
        
        for (_, groupConfig) in groupConfigurations {
            for (_, propConfig) in groupConfig.animationConfigurations {
                groupConfig.animationGroup.animations?.append(propConfig.propertyAnimation)
            }
        }
        
        guard let parentAnimation = (groupConfigurations[animationKey!]?.animationGroup) else  {
            return
        }

        if sequence.rootSequenceAnimation == nil {
            sequence.setRootSequenceAnimation(parentAnimation, onView: associatedView!)
        }
        
        sequence.startSequence()
    }
    
    internal func triggerAnimation(timingPriority : FAPrimaryTimingPriority = .MaxTime,
                                   timeBased : Bool,
                                   view: UIView,
                                   progress: CGFloat = 0.0,
                                   @noescape animator: (animator : FlightAnimator) -> Void) {
        
        guard let parentAnimation = (groupConfigurations[animationKey!]?.animationGroup) else  {
            return
        }

        let triggerKey = NSUUID().UUIDString
        
        for (_, groupConfig) in groupConfigurations {
            for (_, propConfig) in groupConfig.animationConfigurations {
                groupConfigurations[animationKey!]?.animationGroup.animations?.append(propConfig.propertyAnimation)
            }
        }
        
        if sequence.rootSequenceAnimation == nil {
            parentAnimation.sequenceDelegate = sequence
            sequence.setRootSequenceAnimation(parentAnimation, onView: associatedView!)
        }
        
        let newAnimator = FlightAnimator(withView: view, forKey : triggerKey)
        animator(animator : newAnimator)
        
        for (_, groupConfig) in newAnimator.groupConfigurations {
            for (_, propConfig) in groupConfig.animationConfigurations {
                newAnimator.groupConfigurations[triggerKey]?.animationGroup.animations?.append(propConfig.propertyAnimation)
            }
        }
        
        
        if timeBased && progress == 0.0 {
            parentAnimation.appendSequenceAnimationOnStart(newAnimator.groupConfigurations[triggerKey]!.animationGroup, onView: view)
        } else if timeBased && progress > 0.0 {
            parentAnimation.appendSequenceAnimation(newAnimator.groupConfigurations[triggerKey]!.animationGroup, onView: view, atProgress : progress)
        } else if timeBased == false {
            parentAnimation.appendSequenceAnimation(newAnimator.groupConfigurations[triggerKey]!.animationGroup, onView: view, atValueProgress : progress)
        }
    }
}

public class GroupAnimationConfig  {
    
    let animationGroup = FAAnimationGroup()
    
    var animationConfigurations = [String : PropertyAnimationConfig]()
    let animationKey : String = String(NSUUID().UUIDString)
    let animatingLayer : CALayer?

    init(view : UIView, animationKey : String?) {
        animatingLayer = view.layer
    }
}

public class PropertyAnimationConfig  {

    let propertyAnimation = FABasicAnimation()

    var toValue : Any
    var easingCurve : FAEasing = .Linear
    
    init(value: Any, forKeyPath key : String, view : UIView) {
        
        propertyAnimation.keyPath = key
        toValue = value
        
        if let currentValue = toValue as? CGPoint {
            propertyAnimation.toValue =  NSValue(CGPoint :currentValue)
        } else  if let currentValue = toValue as? CGSize {
            propertyAnimation.toValue = NSValue( CGSize :currentValue)
        } else  if let currentValue = toValue as? CGRect {
            propertyAnimation.toValue = NSValue( CGRect : currentValue)
        } else  if let currentValue = toValue as? CGFloat {
            propertyAnimation.toValue = currentValue
        } else  if let currentValue = toValue as? CATransform3D {
            propertyAnimation.toValue =  NSValue( CATransform3D : currentValue)
        } else if let currentValue = typeCastCGColor(toValue) {
            propertyAnimation.toValue = currentValue
        }

        propertyAnimation.animatingLayer = view.layer
        propertyAnimation.easingFunction = .Linear
        propertyAnimation.duration = 0.0
        propertyAnimation.isPrimary = false
    }

    public func duration(duration : CGFloat) -> PropertyAnimationConfig {
        propertyAnimation.duration = Double(duration)
        return self
    }
    
    public func easing(easing : FAEasing) -> PropertyAnimationConfig {
        propertyAnimation.easingFunction = easing
        return self
    }
    
    public func primary(primary : Bool) -> PropertyAnimationConfig {
        propertyAnimation.isPrimary = primary
        return self
    }
}