//
//  Utils.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 5/30/16.
//  Copyright © 2016 Vet's First Choice. All rights reserved.
//

import UIKit


func displayMessage(title: String, message: String, preferredStyle: UIAlertControllerStyle, alertTitle: String, vc: UIViewController) {
	let a = UIAlertController(title: title, message: message,   preferredStyle: preferredStyle)
	let OKAction = UIAlertAction(title: alertTitle, style: .Default) { (action) in
	}
	a.addAction(OKAction)
	vc.presentViewController(a, animated: true){

	}
}