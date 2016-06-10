//
//  API.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 6/5/16.
//  Copyright © 2016 Vet's First Choice. All rights reserved.
//

import Foundation

func getCurrentKeg(completion: (NSDictionary) -> Void) {
	let request = NSMutableURLRequest(URL: NSURL(string: "https://www.theofficekeg.com/kegs/active")!)
	request.HTTPMethod = "GET"
	request.setValue("application/json", forHTTPHeaderField: "Content-Type")
	let config = NSURLSessionConfiguration.defaultSessionConfiguration()
	let session = NSURLSession(configuration: config)

	let task : NSURLSessionDataTask = session.dataTaskWithRequest(request) {(data, response, error) -> Void in
		do {
			let res_data : NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
			if res_data["success"] as! Int > 0 {
				let data = res_data.valueForKey("data") as! NSDictionary
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

func watchBuy(keg_id: String) -> Void {
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