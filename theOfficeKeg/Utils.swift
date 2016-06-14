//
//  Utils.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 5/30/16.
//  Copyright © 2016 Vet's First Choice. All rights reserved.
//

import UIKit


func displayMessage(_ title: String, message: String, preferredStyle: UIAlertControllerStyle, alertTitle: String, vc: UIViewController) {
	let a = UIAlertController(title: title, message: message,   preferredStyle: preferredStyle)
	let OKAction = UIAlertAction(title: alertTitle, style: .default) { (action) in
	}
	a.addAction(OKAction)
	vc.present(a, animated: true){

	}
}

func serverBuy(_ vc: UIViewController, keg_id: String) -> Void {
	let request = NSMutableURLRequest(url: URL(string: "https://www.theofficekeg.com/purchases/add")!)
	request.httpMethod = "POST"
	request.setValue("application/json", forHTTPHeaderField: "Content-Type")
	let str = "{\"keg_id\":\"\(keg_id)\"}"
	request.httpBody = str.data(using: String.Encoding.unicode)

	let config = URLSessionConfiguration.default()
	let session = URLSession(configuration: config)


	let task : URLSessionDataTask = session.dataTask(with: request) {(data, response, error) -> Void in
		do {
			let res_data : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
			if res_data["success"] as! Int > 0 {
				DispatchQueue.main.async(execute: { () -> Void in
					displayMessage("Enjoy your beer!", message: "\(res_data["message"])", preferredStyle: UIAlertControllerStyle.actionSheet, alertTitle: "OK", vc: vc)
				})
			} else {
				DispatchQueue.main.async(execute: { () -> Void in
					displayMessage("Buying Error", message: (res_data["message"] as? String)!, preferredStyle: UIAlertControllerStyle.actionSheet, alertTitle: "OK", vc: vc)
				})
			}
		} catch let JSONErr {
			DispatchQueue.main.async(execute: { () -> Void in
				displayMessage("Buying Error", message: "\(JSONErr)", preferredStyle: UIAlertControllerStyle.actionSheet, alertTitle: "OK", vc: vc)
			})
		}
	}
	task.resume()
}
