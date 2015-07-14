//
//  LoginViewController.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 7/13/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import UIKit
import Foundation

class LoginViewController: UIViewController {
    @IBOutlet var btnLogin: UIButton?
    @IBOutlet var txtUsername: UITextField?
    @IBOutlet var txtPassword: UITextField?
    
    @IBAction
    func btnLoginTap() {
        let request = NSURLRequest(URL: NSURL(string: "https://www.theofficekeg.com/users/login")!)
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
        })!
        task.resume()
    }
    
    override func viewDidLoad() {
        
    }
}
