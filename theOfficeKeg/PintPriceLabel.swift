//
//  PintPriceLabel.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 6/17/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import UIKit

class PintPriceLabel: UILabel {
    
    internal var displayText: String? = "$1" {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    internal var roundRectCornerRadius: CGFloat = 15 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    internal var roundRectColor: UIColor = UIColor.yellowColor() {
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
        self.text = displayText
        self.textAlignment = NSTextAlignment.Center
        self.backgroundColor = roundRectColor
        self.textColor = UIColor.blackColor()
        self.layer.cornerRadius = roundRectCornerRadius
        self.clipsToBounds = true
        addConstraint(NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .GreaterThanOrEqual, toItem: self, attribute: .Height, multiplier: 1, constant: 0))
    }
    
}
