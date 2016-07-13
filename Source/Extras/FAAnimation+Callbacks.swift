//
//  CAAnimation+Callbacks.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 4/22/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

public typealias FAAnimationDidStart = ((anim: CAAnimation) -> Void)
public typealias FAAnimationDidStop  = ((anim: CAAnimation, complete: Bool) -> Void)

class FAAnimationDelegate : NSObject {

    var animationDidStart : FAAnimationDidStart?
    var animationDidStop : FAAnimationDidStop?
    
    override func animationDidStart(_ anim: CAAnimation) {
        if let startCallback = animationDidStart {
            startCallback(anim : anim)
        }
    }
    
    override func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let stopCallback = animationDidStop {
            stopCallback(anim : anim, complete: flag)
          
        }
    }
    
    func setDidStopCallback(_ stopCallback : FAAnimationDidStop) {
        animationDidStop = stopCallback
    }
    
    func setDidStartCallback(_ startCallback : FAAnimationDidStart) {
        animationDidStart = startCallback
    }
}

public extension CAAnimation {
    
    public func setDidStopCallback(_ stopCallback : FAAnimationDidStop) {
       
        if callbacksSupported() == false {
            print("DidStopCallbacks are not supported for \(self)")
        }
        
        var activeDelegate : FAAnimationDelegate?
        
        if let currentDelegate = delegate as? FAAnimationDelegate {
            activeDelegate = currentDelegate
        } else {
            activeDelegate = FAAnimationDelegate()
        }
 
        activeDelegate!.setDidStopCallback { (anim, complete) in
            if let _ = self.delegate as? FAAnimationDelegate {
                stopCallback(anim : anim, complete: complete)
            }
        }
        
        self.delegate = activeDelegate
    }
    
    public func setDidStartCallback(_ startCallback : FAAnimationDidStart) {
        
        if callbacksSupported() == false {
            print("DidStartCallback are not supported for \(self)")
        }
        
        var activeDelegate : FAAnimationDelegate?
        
        if let currentDelegate = delegate as? FAAnimationDelegate {
            activeDelegate = currentDelegate
        } else {
            activeDelegate = FAAnimationDelegate()
        }
        activeDelegate!.setDidStartCallback { (anim) in
            if let _ = self.delegate as? FAAnimationDelegate {
                startCallback(anim : anim)
            }
        }
        
        self.delegate = activeDelegate
    }
    
    private func callbacksSupported() -> Bool {
        if let _ = self as? FAAnimationGroup {
        } else if let _ = self as? FAAnimation {
        } else{
            return false
        }
        return true
    }
}
