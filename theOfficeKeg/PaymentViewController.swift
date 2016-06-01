//
//  PaymentViewController.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 5/31/16.
//  Copyright © 2016 Vet's First Choice. All rights reserved.
//

import UIKit
import Stripe

class PaymentViewController : UIViewController, STPPaymentCardTextFieldDelegate {
	let paymentTextField = STPPaymentCardTextField()

	override func viewDidLoad() {
		super.viewDidLoad()
		paymentTextField.frame = CGRectMake(15, 15, CGRectGetWidth(self.view.frame) - 30, 44)
		paymentTextField.delegate = self
		view.addSubview(paymentTextField)
	}

	func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
		
	}
}
