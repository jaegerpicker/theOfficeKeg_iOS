//
//  DataViewController.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 6/14/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import UIKit

class DataViewController: UIViewController {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblCurrentBeer: UILabel!
    @IBOutlet weak var lblBrewer: UILabel!
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblLastBeer: UILabel!
    @IBOutlet weak var lblBeerPrice: PintPriceLabel!
    var dataObject: String = ""
    var brewer: String = ""
    var lastbeer: String = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.imgAvatar.layer.cornerRadius = self.imgAvatar.frame.size.width / 2
        self.imgAvatar.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }


}

