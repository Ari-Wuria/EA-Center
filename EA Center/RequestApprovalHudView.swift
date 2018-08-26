//
//  RequestHudView.swift
//  EA Center
//
//  Created by Tom Shen on 2018/8/26.
//  Copyright © 2018 Tom Shen. All rights reserved.
//

import UIKit

// Code from iOS Apprentice: http://www.raywenderlich.com
class RequestApprovalHudView: UIView {
    var text = ""
    
    class func hud(in view: UIView, animated: Bool) -> RequestApprovalHudView {
        let hudView = RequestApprovalHudView(frame: view.bounds)
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        //hudView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        hudView.show(animated: animated)
        return hudView
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        // Calculate box location
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2
        ), width: boxWidth, height: boxHeight)
        
        // Draw box
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        // Pic from iOS Apprentice
        // Draw image
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2), y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        
        // Draw text
        let attribs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
                       NSAttributedString.Key.foregroundColor: UIColor.white]
        let textSize = text.size(withAttributes: attribs)
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    func show(animated: Bool) {
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}
