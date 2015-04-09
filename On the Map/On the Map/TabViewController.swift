//
//  TabViewController.swift
//  On the Map
//
//  Created by Daniel Riehs on 3/23/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController {
    

    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    @IBAction func tapRefreshButton(sender: AnyObject) {
        self.refreshData()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        //Checks to see if flag has been set to true by AddPinViewController.
        if MapPoints.sharedInstance().needToRefreshData {
            MapPoints.sharedInstance().needToRefreshData = false
            refreshData()
        }
    }


    //Reloads the data on the Map and Table views.
    func refreshData() {
        //The disabled refresh button indicates that the refresh is in progress.
        self.refreshButton.enabled = false
        
        //This function fetches the latest data from the server.
        MapPoints.sharedInstance().fetchData() { (success, errorString) in
            if !success {
                dispatch_async(dispatch_get_main_queue(), {
                    let controller: UIAlertController = UIAlertController(title: "Error", message: "Error loading map data. Tap Refresh to try again.", preferredStyle: .Alert)
                    controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(controller, animated: true, completion: nil)
                    
                    //The user can try refreshing again.
                    self.refreshButton.enabled = true
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    if let viewControllers = self.viewControllers {
                        for viewController in viewControllers {
                            (viewController as! ReloadableTab).reloadViewController()
                        }
                    }
                    
                    //The re-enabled refresh button indicates that the refresh is complete.
                    self.refreshButton.enabled = true
                })
            }
        }
    }
}
