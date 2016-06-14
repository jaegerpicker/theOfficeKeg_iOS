//
//  DataViewController.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 6/14/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import UIKit
import Stripe


class DataViewController: UIViewController, LoginViewControllerDelegate, PKPaymentAuthorizationViewControllerDelegate {
	
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
	var complete :((NSDictionary) -> Void)!
	func delay(_ delay: Double, closure:()->()){
		DispatchQueue.main.after(when: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
	}
	
		
	func updateDataView() {
		if(dataRetrieved) {
			let dateFormatter = DateFormatter()
			let theDateFormat = DateFormatter.Style.shortStyle
			let theTimeFormat = DateFormatter.Style.shortStyle
			dateFormatter.dateStyle = theDateFormat
			dateFormatter.timeStyle = theTimeFormat
			let beerTime = dateFormatter.string(from: self.lastPurchase.created! as Date) + ": "
			let user_name = (self.lastPurchase.user?.first_name)! + " " + (self.lastPurchase.user?.last_name)!
			let last_beer_string = beerTime + user_name + " enjoyed a beer"
			DispatchQueue.main.async(execute: { () -> Void in
				if self.lblLastBeer.text == last_beer_string {
					self.imgAvatar.imageFromUrl("https://www.gravatar.com/avatar/" +   (self.lastPurchase.user?.email?.MD5())! + ".jpg?s=200&r=x&d=identicon")
				}
				self.lblLastBeer.text = last_beer_string
				self.lblCurrentBeer.text = self.currentKeg.beer_name
				self.lblBrewer.text = self.currentKeg.brewery_name
				let price = self.currentKeg.pint_price
				let nf = NumberFormatter()
				nf.numberStyle = NumberFormatter.Style.currency
				let price_format = nf.string(from: price!)
				self.lblBeerPrice.displayText = price_format!
			})
			
		}
	}
	
	func getLastPurchase() {
		let request = NSMutableURLRequest(url: URL(string: "https://www.theofficekeg.com/purchases/latest")!)
		request.httpMethod = "GET"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		let config = URLSessionConfiguration.default()
		let session = URLSession(configuration: config)
		
		let task : URLSessionDataTask = session.dataTask(with: request) {(data, response, error) -> Void in
			do {
				let res_data : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
				if res_data["success"] as! Int > 0 {
					let pdata = res_data.value(forKey: "data") as! NSDictionary
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
		btnAccount.isHidden = true
		btnYourTab.isHidden = true
		complete = ({(data: NSDictionary) -> Void in
			self.currentKeg.createFromNSDictionary(data)
			self.getLastPurchase()
			self.delay(5.0, closure: {
				getCurrentKeg(self.complete)
			})
		})
		getCurrentKeg(complete)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
	func vcDidFinish(_ controller: LoginViewController, user: User) {
		self.logged_in_user = user
		if(loginVC != nil) {
			controller.dismiss(animated: true, completion: { () in
				print("Back to Main view")
				
			})
			self.logged_in_user?.loggedIn = true
			DispatchQueue.main.async(execute: { () -> Void in
				self.btnAccount.isHidden = false
				self.btnAccount.layoutIfNeeded()
				self.btnYourTab.isHidden = false
				self.btnYourTab.layoutIfNeeded()
				if let tab = self.logged_in_user!.balance {
					self.btnYourTab.setTitle("Your Tab: \(tab)", for: UIControlState())
				} else {
					self.btnYourTab.setTitle("Your Tab: 0.0", for: UIControlState())
				}
				self.btnLogin.setTitle("Signout", for: UIControlState())
			})
		}
	}
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: AnyObject?) -> Bool {
		if identifier == "signin" {
			if btnLogin.titleLabel!.text == "Signin" {
				return true
			} else {
				let request = NSMutableURLRequest(url: URL(string: "https://www.theofficekeg.com/users/logout")!)
				request.httpMethod = "GET"
				request.setValue("application/json", forHTTPHeaderField: "Content-Type")
				let config = URLSessionConfiguration.default()
				let session = URLSession(configuration: config)
				
				let task : URLSessionDataTask = session.dataTask(with: request) {(data, response, error) -> Void in
					do {
						NSLog("data back: \(data)")
						NSLog("response: \(response)")
						let res_data : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
						NSLog("data parsed: \(res_data)")
						if res_data["success"] as! Int > 0 {
							DispatchQueue.main.async(execute: { () -> Void in
								self.currentUser = User()
								self.btnLogin.setTitle("Signin", for: UIControlState())
								self.btnYourTab.isHidden = true
								self.btnAccount.isHidden = true
							})
						} else {
							DispatchQueue.main.async(execute: { () -> Void in
								displayMessage("Signout Error", message: (res_data["message"] as? String)!, preferredStyle: UIAlertControllerStyle.actionSheet, alertTitle: "Ok", vc: self)
							})
						}
					} catch let JSONErr {
						DispatchQueue.main.async(execute: { () -> Void in
							displayMessage("Signout Error", message: "\(JSONErr)", preferredStyle: UIAlertControllerStyle.actionSheet, alertTitle: "Ok", vc: self)
						})
					}
				}
				task.resume()
				return false
			}
		}
		return true
	}
	
	@IBAction func buyAPint(_ sender: AnyObject) {
		if (self.logged_in_user?.loggedIn == true) {
			guard let pay_request = Stripe.paymentRequest(withMerchantIdentifier: "merchant.com.vetsfirstchoice.theofficekeg") else {
				// request will be nil if running on < iOS8
				return
			}
			pay_request.paymentSummaryItems = [
				PKPaymentSummaryItem(label: "\(currentKeg.beer_name!) by \(currentKeg.brewery_name!)", amount: NSDecimalNumber(decimal:currentKeg.pint_price!.decimalValue) )
			]

			if (Stripe.canSubmitPaymentRequest(pay_request)) {
				let paymentController = PKPaymentAuthorizationViewController(paymentRequest: pay_request)
				paymentController.delegate = self
				self.present(paymentController, animated: true, completion: nil)
			} else {
				serverBuy(self, keg_id: currentKeg.id!)
			}

		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: AnyObject!) {
		if segue.identifier == "signin"{
			let vc = segue.destinationViewController as! LoginViewController
			if let user = self.logged_in_user {
				vc.logged_in_user = user
			} else {
				vc.logged_in_user = User()
			}
			vc.delegate = self
			loginVC = vc
		}
	}

	func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> Void) {
		handlePaymentAuthorizationWithPayment(payment, completion: completion)
	}

	func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
		dismiss(animated: true, completion: nil)
	}

	func handlePaymentAuthorizationWithPayment(_ payment: PKPayment, completion: (PKPaymentAuthorizationStatus) -> ()) {
		STPAPIClient.shared().createToken(with: payment) { (token, error) -> Void in
			if error != nil {
				completion(PKPaymentAuthorizationStatus.failure)
				return
			}
			self.createBackendChargeWithToken(token!, completion: completion)
		}
	}

	/*
	*
	* This still needs to be implemented server side!
	*/
	func createBackendChargeWithToken(_ token: STPToken, completion: (PKPaymentAuthorizationStatus) -> ()) {
		let url = URL(string: "https://theofficekeg.com/token")!
		let request = NSMutableURLRequest(url: url)
		request.httpMethod = "POST"
		let body = "stripeToken=(token.tokenId)"
		request.httpBody = body.data(using: String.Encoding.utf8)
		let configuration = URLSessionConfiguration.ephemeral()
		let session = URLSession(configuration: configuration)
		let task = session.dataTask(with: request) { (data, response, error) -> Void in
			if error != nil {
				completion(PKPaymentAuthorizationStatus.failure)
			}
			else {
				completion(PKPaymentAuthorizationStatus.success)
			}
		}
		task.resume()
	}

	func paymentAuthorizationViewControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationViewController) {
		print("Will auth")
	}
}

