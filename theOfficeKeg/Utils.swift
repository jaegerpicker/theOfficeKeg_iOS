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

func serverBuy(vc: UIViewController, keg_id: String) -> Void {
	let request = NSMutableURLRequest(URL: NSURL(string: "https://www.theofficekeg.com/purchases/add")!)
	request.HTTPMethod = "POST"
	request.setValue("application/json", forHTTPHeaderField: "Content-Type")
	let str = "{\"keg_id\":\"\(keg_id)\"}"
	request.HTTPBody = str.dataUsingEncoding(NSStringEncoding())

	let config = NSURLSessionConfiguration.defaultSessionConfiguration()
	let session = NSURLSession(configuration: config)


	let task : NSURLSessionDataTask = session.dataTaskWithRequest(request) {(data, response, error) -> Void in
		do {
			let res_data : NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
			if res_data["success"] as! Int > 0 {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					displayMessage("Enjoy your beer!", message: "\(res_data["message"])", preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "OK", vc: vc)
				})
			} else {
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					displayMessage("Buying Error", message: (res_data["message"] as? String)!, preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "OK", vc: vc)
				})
			}
		} catch let JSONErr {
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				displayMessage("Buying Error", message: "\(JSONErr)", preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "OK", vc: vc)
			})
		}
	}
	task.resume()
}
