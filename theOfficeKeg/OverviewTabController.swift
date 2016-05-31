//
//  OverviewTabController.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 5/31/16.
//  Copyright © 2016 Vet's First Choice. All rights reserved.
//

import UIKit

class OverviewTabController: UIViewController {
	@IBOutlet var Cancel: UIButton!


	@IBAction func tapCancel(sender: UIButton) -> Void {
		self.tabBarController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
}