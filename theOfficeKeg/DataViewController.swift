//
//  DataViewController.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 6/14/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import UIKit
import Alamofire

class DataViewController: UIViewController, LoginViewControllerDelegate {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnAccount: UIButton!
    @IBOutlet weak var lblCurrentBeer: UILabel!
    @IBOutlet weak var lblBrewer: UILabel!
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblLastBeer: UILabel!
    @IBOutlet weak var lblBeerPrice: PintPriceLabel!
    @IBOutlet weak var btnYourTab: UIButton!
    var dataObject: String = ""
    var brewer: String = ""
    var lastbeer: String = ""
    var logged_in_user: User?
    var loginVC: LoginViewController?
    var currentKeg: Keg = Keg()
    var currentUser: User = User()
    var lastPurchase: Purchase = Purchase()
    var dataView: DataViewController? = nil
    var dataRetrieved: Bool = false
    func delay(delay: Double, closure:()->()){
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func getCurrentKeg() {
        Alamofire.request(.GET, URLString: "https://www.theofficekeg.com/kegs/active")
            .responseJSON { (a, b, JSON, c) in
                let keg_data = JSON as! NSDictionary
                let data = keg_data.valueForKey("data") as! NSDictionary
                print(data["beer_name"])
                self.currentKeg.createFromNSDictionary(data)
                self.getLastPurchase()
                self.delay(5.0) {
                    self.getCurrentKeg()
                }
        }
    }
    
    func updateDataView() {
        if(dataRetrieved) {
            let dateFormatter = NSDateFormatter()
            let theDateFormat = NSDateFormatterStyle.ShortStyle
            let theTimeFormat = NSDateFormatterStyle.ShortStyle
            dateFormatter.dateStyle = theDateFormat
            dateFormatter.timeStyle = theTimeFormat
            let beerTime = dateFormatter.stringFromDate(self.lastPurchase.created!) + ": "
            let user_name = (self.lastPurchase.user?.first_name)! + " " + (self.lastPurchase.user?.last_name)!
            let last_beer_string = beerTime + user_name + " enjoyed a beer"
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.lblLastBeer.text == last_beer_string {
                    self.imgAvatar.imageFromUrl("https://www.gravatar.com/avatar/" +   (self.lastPurchase.user?.email?.MD5())! + ".jpg?s=200&r=x&d=identicon")
                }
                self.lblLastBeer.text = last_beer_string
                self.lblCurrentBeer.text = self.currentKeg.beer_name
                self.lblBrewer.text = self.currentKeg.brewery_name
                let price = self.currentKeg.pint_price
                let nf = NSNumberFormatter()
                nf.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                let price_format = nf.stringFromNumber(price!)
                self.lblBeerPrice.displayText = price_format!
            })
            
        }
    }
    
    func getLastPurchase() {
        Alamofire.request(.GET, URLString: "https://www.theofficekeg.com/purchases/latest")
            .responseJSON{ (response, request, JSON, error) in
                print(error)
                let purchase_data = JSON as! NSDictionary
                let pdata = purchase_data.valueForKey("data") as! NSDictionary
                print(pdata)
                self.lastPurchase.createFromNSDictionary(pdata)
                let p_user :User = User()
                let p_user_dic = pdata["user"] as! NSDictionary
                p_user.createFromNSDictionary(p_user_dic)
                self.lastPurchase.user = p_user
                self.dataRetrieved = true
                self.updateDataView()
        }
    }




    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.btnBuy.backgroundColor = UIColor.blackColor()
        self.imgAvatar.layer.cornerRadius = self.imgAvatar.frame.size.width / 2
        self.imgAvatar.clipsToBounds = true
        btnAccount.hidden = true
        btnYourTab.hidden = true
        getCurrentKeg()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func vcDidFinish(controller: LoginViewController, user: User) {
        self.logged_in_user = user
        if(loginVC != nil) {
            controller.dismissViewControllerAnimated(true, completion: { () in
                print("Back to Main view")
                
            })
        }
//        controller.navigationController?.popViewControllerAnimated(true)
        //controller.parentViewController?.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "signin"{
            let vc = segue.destinationViewController as! LoginViewController
            vc.logged_in_user = self.logged_in_user
            vc.delegate = self
            loginVC = vc
        }
    }
}

