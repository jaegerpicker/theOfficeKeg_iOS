//
//  DataViewController.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 6/14/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import UIKit


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
					//print(data["beer_name"])
					self.currentKeg.createFromNSDictionary(data)
					self.getLastPurchase()
					self.delay(5.0, closure: {
						self.getCurrentKeg()
					})
				} else {
					NSLog(res_data["message"]as! String)
				}
			} catch let JSONErr {
				NSLog("\(JSONErr)")
			}
		}
		task.resume()
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
		let request = NSMutableURLRequest(URL: NSURL(string: "https://www.theofficekeg.com/purchases/latest")!)
		request.HTTPMethod = "GET"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		let session = NSURLSession(configuration: config)
		
		let task : NSURLSessionDataTask = session.dataTaskWithRequest(request) {(data, response, error) -> Void in
			do {
				let res_data : NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
				if res_data["success"] as! Int > 0 {
					let pdata = res_data.valueForKey("data") as! NSDictionary
					//print(pdata)
					self.lastPurchase.createFromNSDictionary(pdata)
					let p_user :User = User()
					let p_user_dic = pdata["user"] as! NSDictionary
					p_user.createFromNSDictionary(p_user_dic)
					self.lastPurchase.user = p_user
					self.dataRetrieved = true
					self.updateDataView()
				} else {
					NSLog(res_data["message"]as! String)
				}
				
			} catch let JSONErr {
				NSLog("\(JSONErr)")
			}
		}
		task.resume()
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
			self.logged_in_user?.loggedIn = true
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				self.btnAccount.hidden = false
				self.btnAccount.layoutIfNeeded()
				self.btnYourTab.hidden = false
				self.btnYourTab.layoutIfNeeded()
				self.btnYourTab.setTitle("\(self.logged_in_user?.balance)", forState: UIControlState.Normal)
				self.btnLogin.setTitle("Signout", forState: UIControlState.Normal)
			})
		}
	}
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if identifier == "signin" {
			if btnLogin.titleLabel!.text == "Signin" {
				return true
			} else {
				let request = NSMutableURLRequest(URL: NSURL(string: "https://www.theofficekeg.com/users/logout")!)
				request.HTTPMethod = "GET"
				request.setValue("application/json", forHTTPHeaderField: "Content-Type")
				let config = NSURLSessionConfiguration.defaultSessionConfiguration()
				let session = NSURLSession(configuration: config)
				
				let task : NSURLSessionDataTask = session.dataTaskWithRequest(request) {(data, response, error) -> Void in
					do {
						NSLog("data back: \(data)")
						NSLog("response: \(response)")
						let res_data : NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
						NSLog("data parsed: \(res_data)")
						if res_data["success"] as! Int > 0 {
							dispatch_async(dispatch_get_main_queue(), { () -> Void in
								self.currentUser = User()
								self.btnLogin.setTitle("Signin", forState: UIControlState.Normal)
								self.btnYourTab.hidden = true
								self.btnAccount.hidden = true
							})
						} else {
							dispatch_async(dispatch_get_main_queue(), { () -> Void in
								displayMessage("Signout Error", message: (res_data["message"] as? String)!, preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "Ok", vc: self)
							})
						}
					} catch let JSONErr {
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							displayMessage("Signout Error", message: "\(JSONErr)", preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "Ok", vc: self)
						})
					}
				}
				task.resume()
				return false
			}
		}
		return true
	}
	
	@IBAction func buyAPint(sender: AnyObject) {
		if (self.logged_in_user?.loggedIn == true) {
			let request = NSMutableURLRequest(URL: NSURL(string: "https://www.theofficekeg.com/purchases/add")!)
			request.HTTPMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			let str = "{\"keg_id\":\"\(currentKeg.id!)\"}"
			request.HTTPBody = str.dataUsingEncoding(NSStringEncoding())

			let config = NSURLSessionConfiguration.defaultSessionConfiguration()
			let session = NSURLSession(configuration: config)
			
			
			let task : NSURLSessionDataTask = session.dataTaskWithRequest(request) {(data, response, error) -> Void in
				do {
					let res_data : NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
					if res_data["success"] as! Int > 0 {
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							let a = UIAlertController(title: "Enjoy your beer!", message: res_data["message"] as? String,   preferredStyle: UIAlertControllerStyle.ActionSheet)
							let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
							}
							a.addAction(OKAction)
							self.presentViewController(a, animated: true){
								
							}
						})
					} else {
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							displayMessage("Buying Error", message: (res_data["message"] as? String)!, preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "OK", vc: self)
						})
					}
				} catch let JSONErr {
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						displayMessage("Buying Error", message: "\(JSONErr)", preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "OK", vc: self)
					})
				}
			}
			task.resume()
		}
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

