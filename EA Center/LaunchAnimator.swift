//
//  LaunchAnimator.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/8.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

class LaunchAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    // Simple fade animation
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        transitionContext.containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            toViewController.view.alpha = 1.0
            // Set status bar as well
            toViewController.setNeedsStatusBarAppearanceUpdate()
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}
