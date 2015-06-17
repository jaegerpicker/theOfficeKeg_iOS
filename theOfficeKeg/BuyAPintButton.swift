//
//  BuyAPintButton.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 6/16/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import UIKit

class BuyAPintButton: UIButton {
    
    internal var roundRectCornerRadius: CGFloat = 12 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    internal var roundRectColor: UIColor = UIColor.whiteColor() {
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
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).CGPath
        shapeLayer.fillColor = roundRectColor.CGColor
        self.layer.insertSublayer(shapeLayer, atIndex:0)
        self.roundedRectLayer = shapeLayer
    }
}
