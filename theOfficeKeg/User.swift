//
//  User.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 7/12/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import Foundation

class User {

	var balance: NSNumber?
	var created: NSDate?
	var email: String?
	var first_name: String?
	var id: String?
	var last_name: String?
	var password: String?
	var scanner_uuid: NSNumber?
	var status: NSNumber?
	var version: NSNumber?
	var purchaces: NSSet?
	var roles: NSSet?
	var loggedIn: Bool?

	func createFromNSDictionary(values: NSDictionary) {
		self.id = values["_id"] as? String
		self.first_name = values["first_name"] as? String
		self.last_name = values["last_name"] as? String
		self.password = values["password"] as? String
		self.email = values["email"] as? String
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale(localeIdentifier: "US_en")
		formatter.dateFormat = "yyyy-mm-ddTHH:mm:ss"
		let date = formatter.dateFromString((values["created"] as? String)!)
		self.created = date
		self.balance = values["balance"] as? NSNumber
		self.scanner_uuid = values["scanner_uuid"] as? NSNumber
		self.status = values["status"] as? NSNumber
		self.version = values["v"] as? NSNumber
		self.purchaces = nil
		self.roles = values["roles"] as? NSSet
		self.loggedIn = false
	}
}
