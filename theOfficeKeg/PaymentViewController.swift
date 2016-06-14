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
		paymentTextField.frame = CGRect(x: 15, y: 15, width: self.view.frame.width - 30, height: 44)
		paymentTextField.delegate = self
		view.addSubview(paymentTextField)
	}

	func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
		
	}
}
