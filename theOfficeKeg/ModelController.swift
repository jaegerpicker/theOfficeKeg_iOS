//
//  ModelController.swift
//  theOfficeKeg
//
//  Created by Shawn Campbell on 6/14/15.
//  Copyright © 2015 Vet's First Choice. All rights reserved.
//

import UIKit
import Alamofire
import CoreData
/*
 A controller object that manages a simple model -- a collection of month names.
 
 The controller serves as the data source for the page view controller; it therefore implements pageViewController:viewControllerBeforeViewController: and pageViewController:viewControllerAfterViewController:.
 It also implements a custom method, viewControllerAtIndex: which is useful in the implementation of the data source methods, and in the initial configuration of the application.
 
 There is no need to actually create view controllers for each page in advance -- indeed doing so incurs unnecessary overhead. Given the data model, these methods create, configure, and return a new view controller on demand.
 */


class ModelController: NSObject, UIPageViewControllerDataSource {

    var pageData: [String] = []
    
    var currentKeg: Keg = Keg()
    var currentUser: User = User()
    var lastPurchase: Purchase = Purchase()
    var dataView: DataViewController? = nil
    var dataRetrieved: Bool = false


    override init() {
        super.init()
        // Create the data model.
        let dateFormatter = NSDateFormatter()
        pageData = dateFormatter.monthSymbols
        getCurrentKeg()
    }
    
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
                if self.dataView?.lblLastBeer.text == last_beer_string {
                    self.dataView?.imgAvatar.imageFromUrl("https://www.gravatar.com/avatar/" +   (self.lastPurchase.user?.email?.MD5())! + ".jpg?s=200&r=x&d=identicon")
                }
                self.dataView?.lblLastBeer.text = last_beer_string
                self.dataView?.lblCurrentBeer.text = self.currentKeg.beer_name
                self.dataView?.lblBrewer.text = self.currentKeg.brewery_name
                let price = self.currentKeg.pint_price
                let nf = NSNumberFormatter()
                nf.numberStyle = NSNumberFormatterStyle.CurrencyStyle
                let price_format = nf.stringFromNumber(price!)
                self.dataView?.lblBeerPrice.displayText = price_format!
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

    func viewControllerAtIndex(index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index.
        if (self.pageData.count == 0) || (index >= self.pageData.count) {
            return nil
        }

        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewControllerWithIdentifier("DataViewController") as! DataViewController
        dataView = dataViewController
        dataViewController.dataObject = self.pageData[index]
        return dataViewController
    }

    func indexOfViewController(viewController: DataViewController) -> Int {
        // Return the index of the given data view controller.
        // For simplicity, this implementation uses a static array of model objects and the view controller stores the model object; you can therefore use the model object to identify the index.
        return pageData.indexOf(viewController.dataObject) ?? NSNotFound
    }

    // MARK: - Page View Controller Data Source

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index++
        if index == self.pageData.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }

}

