//
//  UIImageView+imageFromUrl.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 7/13/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//
import UIKit
import Foundation



extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(URL: url)
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            let session = NSURLSession(configuration: config)
            
            let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
                //print(response)
                //print(error)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.image = UIImage(data: data!)
                })
                self.layoutIfNeeded()
                
            });
            task.resume()
        }
    }
}