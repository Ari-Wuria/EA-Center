//
//  RotateOutAnimationController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/8.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class RotateOutAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if let fromView = transitionContext.view(forKey: .from) {
            let time = transitionDuration(using: transitionContext)
            UIView.animateKeyframes(withDuration: time, delay: 0, options: .calculationModeCubic, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: {
                    fromView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                    let t = fromView.transform
                    fromView.transform = t.rotated(by: CGFloat(Double.pi/2))
                })
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
                    fromView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    let t = fromView.transform
                    fromView.transform = t.rotated(by: CGFloat(Double.pi))
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25, animations: {
                    fromView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
                    let t = fromView.transform
                    fromView.transform = t.rotated(by: CGFloat(Double.pi*1.5))
                })
                UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                    fromView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                    let t = fromView.transform
                    fromView.transform = t.rotated(by: CGFloat(Double.pi/4))
                })
            }) { finished in
                transitionContext.completeTransition(finished)
            }
        }
    }
}
