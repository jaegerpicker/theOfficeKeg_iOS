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
    public func imageFromUrl(_ urlString: String) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            let config = URLSessionConfiguration.default()
            let session = URLSession(configuration: config)
            
            let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: {(data, response, error) in
                //print(response)
                //print(error)
                DispatchQueue.main.async(execute: { () -> Void in
                    self.image = UIImage(data: data!)
                })
                self.layoutIfNeeded()
                
            });
            task.resume()
        }
    }
}
