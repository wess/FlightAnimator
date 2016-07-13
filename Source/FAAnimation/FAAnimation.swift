//
//  FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

final public class FAAnimation : CAKeyframeAnimation {
    
    weak var weakLayer : CALayer?
    
    // The easing funtion applied to the duration of the animation
    var easingFunction : FAEasing = FAEasing.linear
    
    
    // ToValue for the animation
    var toValue: AnyObject?
    
    
    // The start time of the animation, set by the current time of
    // the layer when it is added. Used by the springs to find the
    // current velocity in motion
    var startTime : CFTimeInterval?
    
    
    // FromValue defined automatically during synchronization
    // based on the presentation layer properties
    internal var fromValue: AnyObject?
    
    
    // Flag used to track the animation as a primary influencer for the
    // overall timing within an animation group.
    //
    // To set the value call `setAnimationAsPrimary(primary : Bool)`
    // To access the value call `isAnimationPrimary() -> Bool`
    //
    // If multiple animations are primary animations are within a group, the
    // group will take use the primaryTimingPriority setting for the group,
    // and will then synchronization the duration across the remaining animations
    //
    // FASpringAnimation types will always be considered primary, due to the
    // fact they calculate their duration dynamically based on the spring
    // configuration, and if configured with a lower duration than other
    // non spring animations, it may not progress to the final value.
    private var primaryAnimation : Bool = false
    
    var springs : Dictionary<String, FASpring>?
    
    func setAnimationAsPrimary(_ primary : Bool) {
        primaryAnimation = primary
    }
    
    func isAnimationPrimary() -> Bool {
        switch self.easingFunction {
        case .springDecay:
            return true
        case .springCustom(_, _, _):
            return true
        default:
            return primaryAnimation
        }
    }
    
    override init() {
        super.init()
        CALayer.swizzleAddAnimation()
        
        calculationMode = kCAAnimationLinear
        fillMode = kCAFillModeForwards
        isRemovedOnCompletion = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func copy(with zone: NSZone?) -> AnyObject {
        let animation = super.copy(with: zone) as! FAAnimation
        animation.weakLayer         = weakLayer
        animation.fromValue         = fromValue
        animation.toValue           = toValue
        animation.easingFunction    = easingFunction
        animation.startTime         = startTime
        animation.springs           = springs
        return animation
    }
    
    func synchronize(runningAnimation animation : FAAnimation? = nil) {
        configureValues(animation)
    }
    
    func scrubToProgress(_ progress : CGFloat) {
        self.weakLayer!.speed = 0.0
        self.weakLayer!.timeOffset = CFTimeInterval(duration * Double(progress))
    }
}

extension FAAnimation {

    private func configureValues(_ runningAnimation : FAAnimation? = nil) {
        if let presentationValue = weakLayer?.presentation()?.anyValueForKeyPath(self.keyPath!) {
           if let currentValue = presentationValue as? CGPoint {
                syncValues(currentValue, runningAnimation : runningAnimation)
            } else  if let currentValue = presentationValue as? CGSize {
                syncValues(currentValue, runningAnimation : runningAnimation)
            } else  if let currentValue = presentationValue as? CGRect {
                syncValues(currentValue, runningAnimation : runningAnimation)
            } else  if let currentValue = presentationValue as? CGFloat {
                syncValues(currentValue, runningAnimation : runningAnimation)
            } else  if let currentValue = presentationValue as? CATransform3D {
                syncValues(currentValue, runningAnimation : runningAnimation)
            } else if let currentValue = typeCastCGColor(presentationValue) {
                syncValues(currentValue, runningAnimation : runningAnimation)
            }
        }
    }

    private func interpolateValues<T : FAAnimatable>(_ toValue : T, currentValue : T, previousFromValue : T?) {
       
        var interpolator  = FAInterpolator(toValue : toValue,
                                           fromValue: currentValue,
                                           previousFromValue : previousFromValue,
                                           duration: CGFloat(duration),
                                           easingFunction : easingFunction)
        
        let config = interpolator.interpolatedAnimationConfig()
        
        springs = config.springs
        duration = config.duration
        values = config.values
    }
    
    private func syncValues<T : FAAnimatable>(_ currentValue : T, runningAnimation : FAAnimation?) {
        
        fromValue = currentValue.valueRepresentation()
        
        synchronizeAnimationVelocity(currentValue, runningAnimation : runningAnimation)
        
        if let typedToValue = (toValue as? NSValue)?.typeValue() as? T {
            
            let previousFromValue = (runningAnimation?.fromValue as? NSValue)?.typeValue() as? T
            interpolateValues(typedToValue, currentValue : currentValue, previousFromValue : previousFromValue)

        } else  if let typedToValue = toValue  as? T {
            
            let previousFromValue = runningAnimation?.fromValue as? T
            interpolateValues(typedToValue, currentValue : currentValue, previousFromValue : previousFromValue)
        }
    }
    
    private func synchronizeAnimationVelocity<T : FAAnimatable>(_ fromValue : T, runningAnimation : FAAnimation?) {
        
        if  let presentationLayer = runningAnimation?.weakLayer?.presentation(),
            let animationStartTime = runningAnimation?.startTime,
            let oldSprings = runningAnimation?.springs {
            
            let currentTime = presentationLayer.convertTime(CACurrentMediaTime(), to: runningAnimation!.weakLayer)
            let deltaTime = CGFloat(currentTime - animationStartTime)
            
            let newVelocity =  fromValue.springVelocity(oldSprings, deltaTime: deltaTime)
            
            switch easingFunction {
            case .springDecay(_):
                easingFunction = .springDecay(velocity: newVelocity)
            case let .springCustom(_,frequency,damping):
                easingFunction = .springCustom(velocity: newVelocity, frequency: frequency, ratio: damping)
            default:
                break
            }
        }
    }
}

extension FAAnimation {
    
    func valueProgress() -> CGFloat {
        if let presentationValue = weakLayer?.presentation()?.anyValueForKeyPath(self.keyPath!) {
            
            if let currentValue = presentationValue as? CGPoint {
                return valueProgress(currentValue)
            } else  if let currentValue = presentationValue as? CGSize {
                return valueProgress(currentValue)
            } else  if let currentValue = presentationValue as? CGRect {
                return valueProgress(currentValue)
            } else  if let currentValue = presentationValue as? CGFloat {
                return valueProgress(currentValue)
            } else  if let currentValue = presentationValue as? CATransform3D {
                return valueProgress(currentValue)
            } else if let currentValue = typeCastCGColor(presentationValue) {
                return valueProgress(currentValue)
            }
        }
    
        return 0.0
    }
    
    func timeProgress() -> CGFloat {
        let currentTime = weakLayer?.presentation()!.convertTime(CACurrentMediaTime(), to: nil)
        let difference = currentTime! - startTime!
        
        return CGFloat(round(100 * (difference / duration))/100) + 0.03333333333
    }
    
    private func valueProgress<T : FAAnimatable>(_ currentValue : T) -> CGFloat {
       
        if let typedToValue = (toValue as? NSValue)?.typeValue() as? T,
           let typedFromValue = (fromValue as? NSValue)?.typeValue() as? T{
            
            return currentValue.magnitudeToValue(typedToValue) / typedFromValue.magnitudeToValue(typedToValue)
       
        } else if let typedToValue = toValue  as? T,
                  let typedFromValue = fromValue  as? T {
            
            return currentValue.magnitudeToValue(typedToValue) / typedFromValue.magnitudeToValue(typedToValue)
        }
        
        return 0.0
    }
}

