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
    var created: NSDate?
    var id: String?
    var locked: NSNumber?
    var price: NSNumber?
    var scan: String?
    var version: NSNumber?
    var keg: Keg?
    var user: User?
    
    func createFromNSDictionary(values: NSDictionary) {
        self.cancelled = values["cancelled"] as? NSNumber
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date_string = (values["created"] as? String)!
        let date = formatter.dateFromString(date_string)
        self.created = date
        self.id = values["_id"] as? String
        self.locked = values["locked"] as? NSNumber
        self.price = values["price"] as? NSNumber
        self.scan = values["scan"] as? String
        self.version = values["v"] as? NSNumber

    }

}
