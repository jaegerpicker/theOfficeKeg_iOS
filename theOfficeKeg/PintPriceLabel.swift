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
    
    internal var roundRectColor: UIColor = UIColor.yellow() {
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
        self.textAlignment = NSTextAlignment.center
        self.backgroundColor = roundRectColor
        self.textColor = UIColor.black()
        self.layer.cornerRadius = roundRectCornerRadius
        self.clipsToBounds = true
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: self, attribute: .height, multiplier: 1, constant: 0))
    }
    
}
