//
//  UIView+AnimationCache.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 6/22/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

private struct FAAssociatedKey {
    static var layoutConfigurations = "layoutConfigurations"
}

extension UIView {
    
    internal var cachedAnimations: [String : FAAnimationGroup]? {
        get {
            return fa_getAssociatedObject(self, associativeKey: &FAAssociatedKey.layoutConfigurations)
        }
        set {
            if let value = newValue {
                fa_setAssociatedObject(self, value: value, associativeKey: &FAAssociatedKey.layoutConfigurations, policy: objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private func fa_setAssociatedObject<T>(_ object: AnyObject,
                                     value: T,
                                     associativeKey: UnsafePointer<Void>,
                                     policy: objc_AssociationPolicy) {
        
        if let v: AnyObject = value as? AnyObject {
            objc_setAssociatedObject(object, associativeKey, v,  policy)
        } else {
            objc_setAssociatedObject(object, associativeKey, ValueWrapper(value),  policy)
        }
    }
    
    private func fa_getAssociatedObject<T>(_ object: AnyObject, associativeKey: UnsafePointer<Void>) -> T? {
        if let v = objc_getAssociatedObject(object, associativeKey) as? T {
            return v
        } else if let v = objc_getAssociatedObject(object, associativeKey) as? ValueWrapper<T> {
            return v.value
        } else {
            return nil
        }
    }
    
    func applyAnimationsToSubViews(_ inView : UIView, forKey key: String, animated : Bool = true) {
        for subView in inView.subviews {
            subView.applyAnimation(forKey: key, animated: animated)
        }
    }
    
    func appendAnimation(_ animation : AnyObject, forKey key: String) {
        
        if self.cachedAnimations == nil {
            cachedAnimations = [String : FAAnimationGroup]()
        }
        
        if let newAnimation = animation as? FAAnimation {
            let newAnimationGroup = FAAnimationGroup()
            newAnimationGroup.animations = [newAnimation]
            newAnimationGroup.weakLayer = layer
            cachedAnimations![key] = newAnimationGroup
        }
        
        if let newAnimationGroup = animation as? FAAnimationGroup {
            newAnimationGroup.weakLayer = layer
            cachedAnimations![key] = newAnimationGroup
        }
    }
    
    internal func attachAnimation(_ animation : AnyObject,
                                  forKey key: String) {
        
        if cachedAnimations != nil {
          //  if let animation = cachedAnimations![key] {
          //      
          //  }
        }
        
        self.appendAnimation(animation, forKey : key)
    }
}

extension Array where Element : Equatable {
    
    mutating func removeObject(_ object : Iterator.Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
    
    func contains<T where T : Equatable>(_ obj: T) -> Bool {
        return filter({$0 as? T == obj}).count > 0
    }
}

final class ValueWrapper<T> {
    let value: T
    init(_ x: T) {
        value = x
    }
}
