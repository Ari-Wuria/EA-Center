//
//  DimmingPresentationController.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/8.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

// Gradient View, this presentation controller, and animation controllers
// are from raywenderlich
class DimmingPresentationController: UIPresentationController {
    lazy var gradientView = GradientView(frame: CGRect.zero)
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        gradientView.frame = containerView!.bounds
        containerView!.insertSubview(gradientView, at: 0)
        
        gradientView.alpha = 0
        
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.gradientView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                self.gradientView.alpha = 0
            }, completion: nil)
        }
    }
}
