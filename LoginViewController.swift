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

protocol LoginViewControllerDelegate{
    func vcDidFinish(_ controller: LoginViewController, user: User)
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
		if let uName = UserDefaults.standard().string(forKey: usernameKey) {
			txtUsername.text = uName
		}
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    @IBAction func btnLoginTap() {
		doLogin(txtUsername.text, password: txtPassword.text)
	}

	private func doLogin(_ username: String?, password: String?) -> Void {
		if password?.isEmpty == false && username?.isEmpty == false {
			let request = NSMutableURLRequest(url: URL(string: "https://www.theofficekeg.com/users/login")!)
			request.httpMethod = "POST"
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			let body = "{\"email\":\"\(username!)\", \"password\":\"\(password!)\"}"
			request.httpBody = body.data(using: String.Encoding.unicode)
			let config = URLSessionConfiguration.default()
			let session = URLSession(configuration: config)

			let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: ({(data, response, error) -> Void in
				do {
					NSLog("data back: \(data)")
					NSLog("response: \(response)")
					let response2 = response as! HTTPURLResponse!
					let cookies = HTTPCookie.cookies(withResponseHeaderFields: response2?.allHeaderFields as![String: String], for: (response?.url)!)
					HTTPCookieStorage.shared().setCookies(cookies, for: response2?.url, mainDocumentURL: nil)
					let res_data : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
					NSLog("data parsed: \(res_data)")
					if res_data["success"] as! Int > 0 {
						let login_result : NSDictionary = res_data["data"] as! NSDictionary
						self.logged_in_user = User()
						self.logged_in_user?.email = login_result["email"] as? String
						self.logged_in_user?.balance = login_result["balance"] as? Float
						let created_date = login_result["created"] as? Date
						self.logged_in_user?.created = created_date
						self.logged_in_user?.first_name = login_result["first_name"] as? String
						self.logged_in_user?.last_name = login_result["last_name"] as? String
						UserDefaults.standard().setValue(username, forKey: self.usernameKey)
						if showTouchID() {
							DispatchQueue.main.async(execute: { () -> Void in
								self.showSaveLoginPrompt(username!, password: password!)
							})
						}
						if((self.delegate) != nil) {
							self.delegate?.vcDidFinish(self, user: self.logged_in_user!)
						}
					} else {
						DispatchQueue.main.async(execute: { () -> Void in
							displayMessage("Signin Error", message: "\(res_data["message"])", preferredStyle: UIAlertControllerStyle.actionSheet, alertTitle: "Ok", vc: self)
						})
					}
				} catch let JSONErr {
					NSLog("caught exception parse data: \(JSONErr)")
					DispatchQueue.main.async(execute: { () -> Void in
						displayMessage("Signin Error", message: "\(JSONErr)", preferredStyle: UIAlertControllerStyle.actionSheet, alertTitle: "Ok", vc: self)
					})
				}
			}))
			task.resume()
		} else {
			displayMessage("Signin Error", message: "You must fill in Username and Password to Signin", preferredStyle: UIAlertControllerStyle.actionSheet, alertTitle: "Ok", vc: self)
		}
		return
	}

	private func showSaveLoginPrompt(_ username: String, password: String) {
		let alert = UIAlertController(title: "TouchID", message: "Would you like to save your creditials using TouchID for future use?", preferredStyle: .alert)

		let yesAction = UIAlertAction(title: "Yes", style: .default) {
			action in
			do {
				try saveUserNameAndPassword(UserAuthKeyChain(userName: username, password:password))
			} catch {
				displayMessage("Save failed", message: "Failed to save your username and password", preferredStyle: UIAlertControllerStyle.actionSheet, alertTitle: "OK", vc: self)
			}
		}
		alert.addAction(yesAction)

		let noAction = UIAlertAction(title: "No", style: .default) {
			action in
			print("Not saving")
		}
		alert.addAction(noAction)

		let neverAgainAction = UIAlertAction(title: "No, and please don't prompt again.", style: .default) {
			action in
			saveTouchIDPref(true)
		}
		alert.addAction(neverAgainAction)
		self.present(alert, animated: true, completion: {})
	}
    
    @IBAction override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
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

	func loginWithTouchID(_ showTouchIDFail: Bool) {
		do {
			let userAuthKeyChain = try retrieveUserAuth()
			self.doLogin(userAuthKeyChain.userName, password: userAuthKeyChain.password)
		} catch {
			displayMessage("Login Error", message: "The attempt to login failed", preferredStyle: UIAlertControllerStyle.actionSheet, alertTitle: "Ok", vc: self)
		}
		
	}
}
