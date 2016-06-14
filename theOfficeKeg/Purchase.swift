//
//  Purchase.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 7/12/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import Foundation

class Purchase {

    var cancelled: NSNumber?
    var created: Date?
    var id: String?
    var locked: NSNumber?
    var price: NSNumber?
    var scan: String?
    var version: NSNumber?
    var keg: Keg?
    var user: User?
    
    func createFromNSDictionary(_ values: NSDictionary) {
        self.cancelled = values["cancelled"] as? NSNumber
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(forSecondsFromGMT: 0)
        formatter.calendar = Calendar(calendarIdentifier: Calendar.Identifier.ISO8601)!
        formatter.locale = Locale(localeIdentifier: "en_US_POSIX")
        let date_string = (values["created"] as? String)!
        let date = formatter.date(from: date_string)
        self.created = date
        self.id = values["_id"] as? String
        self.locked = values["locked"] as? NSNumber
        self.price = values["price"] as? NSNumber
        self.scan = values["scan"] as? String
        self.version = values["v"] as? NSNumber

    }

}
