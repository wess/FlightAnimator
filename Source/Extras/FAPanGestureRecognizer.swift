//
//  FAPanGestureRecognizer.swift
//  FlightAnimator
//
//  Created by Anton Doudarev on 4/23/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit

typealias FAAnimationGesturePossible    = (recognizer : FAPanGestureRecognizer) -> Void
typealias FAAnimationGestureBegan       = (recognizer : FAPanGestureRecognizer) -> Void
typealias FAAnimationGestureChanged     = (recognizer : FAPanGestureRecognizer, startPosition : CGPoint, currentPosition : CGPoint) -> CGFloat
typealias FAAnimationGestureEnded       = (recognizer : FAPanGestureRecognizer) -> Void
typealias FAAnimationGestureCancelled   = (recognizer : FAPanGestureRecognizer) -> Void
typealias FAAnimationGestureFailed      = (recognizer : FAPanGestureRecognizer) -> Void

class FAPanGestureRecognizer : UIPanGestureRecognizer {
    
    var startPosition : CGPoint?
    var currentPosition : CGPoint?
    var animationGroup : FAAnimationGroup?
    
    convenience init(animationGroup : FAAnimationGroup) {
        self.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(FAPanGestureRecognizer.respondToPanRecognizer))
        self.animationGroup = animationGroup
    }
    
    override init(target: AnyObject?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    func copyWithZone(_ zone: NSZone?) -> AnyObject {
        let gesture = self.copy() as! FAPanGestureRecognizer
        gesture.startPosition             = startPosition
        gesture.currentPosition           = currentPosition
        gesture.animationGroup            = animationGroup
        gesture.gesturePossibleCallBack   = gesturePossibleCallBack
        gesture.gestureBeganCallBack      = gestureBeganCallBack
        gesture.gestureChangedCallBack    = gestureChangedCallBack
        gesture.gestureEndedCallBack      = gestureEndedCallBack
        gesture.gestureCancelledCallBack  = gestureCancelledCallBack
        gesture.gestureFailedCallBack     = gestureFailedCallBack
        return gesture
    }
    
    var gesturePossibleCallBack     : FAAnimationGesturePossible?
    var gestureBeganCallBack        : FAAnimationGestureBegan?
    var gestureChangedCallBack      : FAAnimationGestureChanged?
    var gestureEndedCallBack        : FAAnimationGestureEnded?
    var gestureCancelledCallBack    : FAAnimationGestureCancelled?
    var gestureFailedCallBack       : FAAnimationGestureFailed?
    
    func setPossibleCallBack(_ callback : FAAnimationGesturePossible) {
        gesturePossibleCallBack = callback
    }
    
    func setBeganCallBack(_ callback : FAAnimationGestureBegan) {
        gestureBeganCallBack = callback
    }
    
    func setChangedCallBack (_ callback : FAAnimationGestureChanged) {
        gestureChangedCallBack = callback
    }
    
    func setEndedCallBack (_ callback : FAAnimationGestureEnded) {
        gestureEndedCallBack = callback
    }
    
    func setCancelledCallBack(_ callback : FAAnimationGestureCancelled) {
        gestureCancelledCallBack = callback
    }
    
    func setFailedCallBack(_ callback : FAAnimationGestureFailed) {
        gestureFailedCallBack = callback
    }
    
    @objc private func respondToPanRecognizer(_ recognizer : FAPanGestureRecognizer) {
        switch state {
        case .possible:
            if let callback = gesturePossibleCallBack {
                callback(recognizer: self)
            }
        case .began:
            if let animationLayer = animationGroup?.weakLayer,
               let owningView = animationLayer.owningView() {
                startPosition = recognizer.translation(in: owningView.superview)
                animationLayer.speed = 0.0
                animationLayer.add(animationGroup!, forKey: animationGroup?.animationKey)
            }
            
            if let callback = gestureBeganCallBack {
                callback(recognizer: self)
            }
        case .changed:
            if  let callback = gestureChangedCallBack,
                let group = animationGroup,
                let animationLayer = animationGroup?.weakLayer,
                let owningView = animationLayer.owningView() {
                
                let translationPoint = recognizer.translation(in: owningView.superview)
                
                let progress = callback(recognizer: self,
                                        startPosition : startPosition!,
                                        currentPosition: translationPoint)
                
                group.scrubToProgress(progress)
            }
        case .ended:
            if let animationLayer = animationGroup?.weakLayer {
                animationLayer.add(animationGroup!, forKey:  animationGroup?.animationKey)
                animationGroup!.applyFinalState(true)
                
            }

            if let callback = gestureEndedCallBack {
                callback(recognizer: self)
            }
        case .cancelled:
            if let callback = gestureCancelledCallBack {
                callback(recognizer: self)
            }
        case .failed:
            if let callback = gestureFailedCallBack {
                callback(recognizer: self)
            }
        }
    }
}
