//
//  ConfigurationView+Animation.swift
//  FlightAnimator-Demo
//
//  Created by Anton Doudarev on 9/1/16.
//  Copyright © 2016 Anton Doudarev. All rights reserved.
//

import Foundation
import UIKit


extension ConfigurationView {
    
    
    func updateAnimation() {
    
        if delaySegnmentedControl.selectedSegmentIndex == 0 {
            
            atProgressLabel.animate {  [unowned self]  (animator) in
                animator.alpha(0.0).duration(0.5).easing(.InOutSine)
                
                animator.triggerOnProgress(0.01, onView: self.progressLabel, animator: { (animator) in
                    animator.alpha(0.0).duration(0.5).easing(.InOutSine)
                })
                
                animator.triggerOnProgress(0.7, onView: self.enableSecondaryViewLabel, animator: { (animator) in
                    animator.position(self.adjustedPosition).duration(0.5).easing(.InOutSine)
                })
                
                animator.triggerOnProgress(0.1, onView: self.progressTriggerSlider, animator: { (animator) in
                    animator.alpha(0.0).duration(0.5).easing(.InOutSine)
                })
            }
            
        } else  {
            
            enableSecondaryViewLabel.animate { [unowned self] (animator) in
                animator.position(self.initialCenter).duration(0.5).easing(.OutSine)
                
                animator.triggerOnProgress(0.61, onView: self.atProgressLabel, animator: { (animator) in
                    animator.alpha(1.0).duration(0.5).easing(.InOutSine)
                })
                
                animator.triggerOnProgress(0.6, onView: self.progressLabel, animator: { (animator) in
                    animator.alpha(1.0).duration(0.5).easing(.InOutSine)
                })
                
                animator.triggerOnProgress(0.7, onView: self.progressTriggerSlider, animator: { (animator) in
                    animator.alpha(1.0).duration(0.5).easing(.InOutSine)
                })
            }
            
            if lastSelectedDelaySegment != 0 && lastSelectedDelaySegment != delaySegnmentedControl.selectedSegmentIndex {
                
                atProgressLabel.animate(animator: { [unowned self] (animator) in
                    
                    animator.alpha(0.0).duration(0.5).easing(.OutSine)
                    
                    animator.setDidStopCallback({ (anim, complete) in
                        
                        if self.delaySegnmentedControl.selectedSegmentIndex == 1 {
                            self.atProgressLabel.text = "Trigger @ Time Progress:  "
                        } else {
                            self.atProgressLabel.text = "Trigger @ Value Progress: "
                        }
                        
                        self.atProgressLabel.animate(animator: { (animator) in
                            animator.alpha(1.0).duration(0.5).easing(.InSine)
                        })
                    })
                })
            }
      
        }
        lastSelectedDelaySegment = delaySegnmentedControl.selectedSegmentIndex
        interactionDelegate?.didUpdateTriggerType(delaySegnmentedControl.selectedSegmentIndex)
    }

}

