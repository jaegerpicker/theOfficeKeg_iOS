//
//  LoginViewController.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 7/13/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import UIKit
import Foundation
import Security
import PromiseKit

protocol LoginViewControllerDelegate{
    func vcDidFinish(controller: LoginViewController, user: User)
}


class LoginViewController: UIViewController, UIAlertViewDelegate {
    @IBOutlet var btnLogin: UIButton!
	@IBOutlet var btnTouch: UIButton!
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var vwContainer: UIView!
    var delegate: LoginViewControllerDelegate?
    var logged_in_user: User?
	let usernameKey = "VCS_USERNAME"
    
    override func viewDidLoad() {
        vwContainer.layer.cornerRadius = 25
        vwContainer.layer.masksToBounds = true
		if let uName = NSUserDefaults.standardUserDefaults().stringForKey(usernameKey) {
			txtUsername.text = uName
		}
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    @IBAction func btnLoginTap() {
		doLogin(txtUsername.text, password: txtPassword.text)
	}

	private func doLogin(username: String?, password: String?) -> Promise<Void> {
		if password?.isEmpty == false && username?.isEmpty == false {
			let request = NSMutableURLRequest(URL: NSURL(string: "https://www.theofficekeg.com/users/login")!)
			request.HTTPMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			let body = "{\"email\":\"\(username!)\", \"password\":\"\(password!)\"}"
			request.HTTPBody = body.dataUsingEncoding(NSStringEncoding())
			let config = NSURLSessionConfiguration.defaultSessionConfiguration()
			let session = NSURLSession(configuration: config)

			let task : NSURLSessionDataTask = session.dataTaskWithRequest(request) {(data, response, error) -> Void in
				do {
					NSLog("data back: \(data)")
					NSLog("response: \(response)")
					let response2 = response as! NSHTTPURLResponse!
					let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(response2?.allHeaderFields as![String: String], forURL: (response?.URL)!)
					NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(cookies, forURL: response2?.URL, mainDocumentURL: nil)
					let res_data : NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
					NSLog("data parsed: \(res_data)")
					if res_data["success"] as! Int > 0 {
						let login_result : NSDictionary = res_data["data"] as! NSDictionary
						self.logged_in_user = User()
						self.logged_in_user?.email = login_result["email"] as? String
						self.logged_in_user?.balance = login_result["balance"] as? Float
						let created_date = login_result["created"] as? NSDate
						self.logged_in_user?.created = created_date
						self.logged_in_user?.first_name = login_result["first_name"] as? String
						self.logged_in_user?.last_name = login_result["last_name"] as? String
						NSUserDefaults.standardUserDefaults().setValue(username, forKey: self.usernameKey)
						if showTouchID() {
							dispatch_async(dispatch_get_main_queue(), { () -> Void in
								self.showSaveLoginPrompt(username!, password: password!)
							})
						}
						if((self.delegate) != nil) {
							self.delegate?.vcDidFinish(self, user: self.logged_in_user!)
						}
					} else {
						dispatch_async(dispatch_get_main_queue(), { () -> Void in
							displayMessage("Signin Error", message: "\(res_data["message"])", preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "Ok", vc: self)
						})
					}
				} catch let JSONErr {
					NSLog("caught exception parse data: \(JSONErr)")
					dispatch_async(dispatch_get_main_queue(), { () -> Void in
						displayMessage("Signin Error", message: "\(JSONErr)", preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "Ok", vc: self)
					})
				}
			}
			task.resume()
		} else {
			displayMessage("Signin Error", message: "You must fill in Username and Password to Signin", preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "Ok", vc: self)
		}
		return Promise<Void>()
	}

	private func showSaveLoginPrompt(username: String, password: String) {
		let alert = UIAlertController(title: "TouchID", message: "Would you like to save your creditials using TouchID for future use?", preferredStyle: .Alert)

		let yesAction = UIAlertAction(title: "Yes", style: .Default) {
			action in
			saveUserNameAndPassword(UserAuthKeyChain(userName: username, password:password)).then {
				return
				}.always {
					print("Saving")
			}
		}
		alert.addAction(yesAction)

		let noAction = UIAlertAction(title: "No", style: .Default) {
			action in
			print("Not saving")
		}
		alert.addAction(noAction)

		let neverAgainAction = UIAlertAction(title: "No, and please don't prompt again.", style: .Default) {
			action in
			saveTouchIDPref(true)
		}
		alert.addAction(neverAgainAction)
		self.presentViewController(alert, animated: true, completion: {})
	}
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        print(subsequentVC)
    }
    
    @IBAction func btnCancelTap() {
        if((delegate) != nil) {
            logged_in_user = User()
            logged_in_user?.email = "not_logged_in_user@vetsfirstchoice.com"
            delegate?.vcDidFinish(self, user: logged_in_user!)
        }
    }

	@IBAction func displayTouchID() {
		loginWithTouchID(true)
	}

	func loginWithTouchID(showTouchIDFail: Bool) {
		retrieveUserAuth().then {
			userAuthKeyChain -> Promise<Void> in
			return self.doLogin(userAuthKeyChain.userName, password: userAuthKeyChain.password).then {
				_ -> Void in

			}
			}.error(policy: .AllErrors) {
				(error: ErrorType) -> Void in


				if let viewError = error as? ViewError {

					switch viewError {
					case .TouchIDNoId where showTouchIDFail:
						let message = "Unable to retrieve your stored account information, please login with your username and password."
						displayMessage("Login Error", message: message, preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "Ok", vc: self)
					case .TouchIDNoId:
						return
					case .TouchIDCancelled:
						return
					}
				}

				// we use cancelled for a 401 so it can ignore .error blocks except for login.
				let nsError = error as NSError
				if nsError.code == PMKOperationCancelled {
					deleteTouchIDItem()
				}

				let message = NSLocalizedString("LOGIN_FAILURE", comment: "")
				displayMessage("Login Error", message: message, preferredStyle: UIAlertControllerStyle.ActionSheet, alertTitle: "Ok", vc: self)
		}
		
	}
}
