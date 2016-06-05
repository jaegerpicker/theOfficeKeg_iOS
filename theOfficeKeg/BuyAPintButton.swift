//
//  BuyAPintButton.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 6/16/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import UIKit
import Foundation

class BuyAPintButton: UIButton {
    
    internal var roundRectCornerRadius: CGFloat = 12 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    internal var roundRectColor: UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override internal func layoutSubviews() {
        super.layoutSubviews()
        layoutRoundedRect()
    }
    
    private var roundedRectLayer: CAShapeLayer?
    
    private func layoutRoundedRect() {
        if let existingLayer = roundedRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        let frameRect = self.bounds
        let newRect = CGRect(x: frameRect.origin.x - 2,y: frameRect.origin.y - 2, width: frameRect.size.width + 3, height: frameRect.size.height + 3)
        let border : UIBezierPath = UIBezierPath(roundedRect: newRect, cornerRadius: roundRectCornerRadius)
        let borderLayer = CAShapeLayer()
        borderLayer.path = border.CGPath
        borderLayer.fillColor = UIColor.clearColor().CGColor
        borderLayer.strokeColor = UIColor.whiteColor().CGColor
        borderLayer.lineWidth = 6
        self.layer.insertSublayer(borderLayer, atIndex: 0)
    }
}
