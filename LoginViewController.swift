//
//  LoginViewController.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 7/13/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import UIKit
import Foundation

protocol LoginViewControllerDelegate{
    func vcDidFinish(controller: LoginViewController, user: User)
}


class LoginViewController: UIViewController, UIAlertViewDelegate {
    @IBOutlet var btnLogin: UIButton!
    @IBOutlet var txtUsername: UITextField!
    @IBOutlet var txtPassword: UITextField!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var vwContainer: UIView!
    var delegate: LoginViewControllerDelegate?
    var logged_in_user: User?
    
    override func viewDidLoad() {
        vwContainer.layer.cornerRadius = 25
        vwContainer.layer.masksToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    @IBAction func btnLoginTap() {
        if txtPassword.text?.isEmpty == false && txtUsername.text?.isEmpty == false {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.theofficekeg.com/users/login")!)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let username = txtUsername.text
            let password = txtPassword.text
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
                        if((self.delegate) != nil) {
                            self.delegate?.vcDidFinish(self, user: self.logged_in_user!)
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let a = UIAlertController(title: "Signin Error", message: res_data["message"] as? String,   preferredStyle: UIAlertControllerStyle.ActionSheet)
                            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                            }
                            a.addAction(OKAction)
                            self.presentViewController(a, animated: true){
                            
                            }
                        })
                    }
                } catch let jsonError {
                    NSLog("caught exception parse data: \(jsonError)")
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let a = UIAlertController(title: "Signin Error", message: "\(jsonError)",   preferredStyle: UIAlertControllerStyle.ActionSheet)
                        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                        }
                        a.addAction(OKAction)
                        self.presentViewController(a, animated: true){
                            
                        }
                    })
                }
            }
            task.resume()
        } else {
            let a = UIAlertController(title: "Signin Error", message: "You must fill in Username and Password to Signin", preferredStyle: UIAlertControllerStyle.ActionSheet)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            }
            a.addAction(OKAction)
            self.presentViewController(a, animated: true) {
                
            }
        }
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
}
