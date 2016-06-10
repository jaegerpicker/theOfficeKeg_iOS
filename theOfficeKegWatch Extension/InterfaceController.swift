//
//  InterfaceController.swift
//  theOfficeKegWatch Extension
//
//  Created by Shawn Campbell on 6/4/16.
//  Copyright © 2016 Vet's First Choice. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
	
	@IBOutlet var buyAPint: WKInterfaceButton!
	var currentKeg: Keg = Keg()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

	@IBAction func tapBuyAPint(sender: AnyObject) {
		print("Buy A Pint")
		getCurrentKeg({(data) -> Void in
			self.currentKeg.createFromNSDictionary(data)
			print(self.currentKeg)
			watchBuy(self.currentKeg.id!)
		})
	}

}
