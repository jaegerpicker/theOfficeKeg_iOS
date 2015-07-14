//
//  Keg.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 7/12/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import Foundation

class Keg {

    var beer_name: String?
    var brewery_name: String?
    var created: NSDate?
    var id: String?
    var is_active: NSNumber?
    var pint_price: NSNumber?
    var version: NSNumber?
    var relationship: NSSet?
    
    func createFromNSDictionary(values: NSDictionary) {
        self.beer_name = values["beer_name"] as? String
        self.brewery_name = values["brewery_name"] as? String
        self.pint_price = values["pint_price"] as? Float
    }

}
