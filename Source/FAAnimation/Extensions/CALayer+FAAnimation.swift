//
//  CALayer+FAAnimation.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 2/24/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//


import Foundation
import UIKit

var executed = false
extension CALayer {
    
    final public class func swizzleAddAnimation() {
        struct Static {
            static var token: Int = 0
        }
        
        if self !== CALayer.self {
            return
        }
        if executed == false {
        //Dispatch.once(token : token) {
            let originalSelector = #selector(CALayer.add(_:forKey:))
            let swizzledSelector = #selector(CALayer.FA_addAnimation(_:forKey:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
            
            executed = true
        }
    }
    
    internal func FA_addAnimation(_ anim: CAAnimation, forKey key: String?) {
        if let animation = anim as? FAAnimationGroup {
            animation.weakLayer = self
            animation.animationKey = key
            animation.startTime = self.convertTime(CACurrentMediaTime(), from: nil)
            animation.synchronizeAnimationGroup((self.animation(forKey: key!) as? FAAnimationGroup))
        }

        removeAllAnimations()
        FA_addAnimation(anim, forKey: key)
    }

    final public func anyValueForKeyPath(_ keyPath: String) -> Any? {
        if let currentFromValue = self.value(forKeyPath: keyPath) {
            
            if let value = typeCastCGColor(currentFromValue) {
                return value
            }
    
            let type = String(cString: currentFromValue.objCType) ?? ""
            
            if type.hasPrefix("{CGPoint") {
                return currentFromValue.cgPointValue!
            } else if type.hasPrefix("{CGSize") {
                return currentFromValue.cgSizeValue!
            } else if type.hasPrefix("{CGRect") {
                return currentFromValue.cgRectValue!
            } else if type.hasPrefix("{CATransform3D") {
                return currentFromValue.caTransform3DValue!
            }
            else {
                return currentFromValue
            }
        }
        
        return super.value(forKeyPath: keyPath)
    }
    
    final public func owningView() -> UIView? {
        if let owningView = self.delegate as? UIView {
            return owningView
        }
        
        return nil
    }
}

public func typeCastCGColor(_ value : Any) -> CGColor? {
    if let currentValue = value as? AnyObject {
        //TODO: There appears to be no way of unwrapping a CGColor by type casting
        //Fix when the following bug is fixed https://bugs.swift.org/browse/SR-1612
        if CFGetTypeID(currentValue) == CGColor.typeID {
            return (currentValue as! CGColor)
        }
    }
    
    return nil
}
