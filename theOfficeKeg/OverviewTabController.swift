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


	@IBAction func tapCancel(_ sender: UIButton) -> Void {
		self.tabBarController?.dismiss(animated: true, completion: nil)
	}
	
}
