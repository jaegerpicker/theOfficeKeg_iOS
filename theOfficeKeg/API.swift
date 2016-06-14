//
//  API.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 6/5/16.
//  Copyright © 2016 Vet's First Choice. All rights reserved.
//

import Foundation

func getCurrentKeg(_ completion: (NSDictionary) -> Void) {
	let request = NSMutableURLRequest(url: URL(string: "https://www.theofficekeg.com/kegs/active")!)
	request.httpMethod = "GET"
	request.setValue("application/json", forHTTPHeaderField: "Content-Type")
	let config = URLSessionConfiguration.default()
	let session = URLSession(configuration: config)

	let task : URLSessionDataTask = session.dataTask(with: request) {(data, response, error) -> Void in
		do {
			let res_data : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
			if res_data["success"] as! Int > 0 {
				let data = res_data.value(forKey: "data") as! NSDictionary
				completion(data)
			} else {
				NSLog(res_data["message"]as! String)
			}
		} catch let JSONErr {
			NSLog("\(JSONErr)")
		}
	}
	task.resume()
}

func watchBuy(_ keg_id: String) -> Void {
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
					print("Enjoy the beer")
				} else {
					print(res_data["message"])
				}
			} catch let JSONErr {
				print(JSONErr)
			}
	}
	task.resume()
}
