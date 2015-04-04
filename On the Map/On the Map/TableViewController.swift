//
//  TableViewController.swift
//  On the Map
//
//  Created by Daniel Riehs on 3/22/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    
    //The table is reloaded every time the view appears, but new data will only be available if the MapPoints.fetchData() function has been called.
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    
    //The data for the table cells is stored in the mapPonts array in the sharedInstace of the MapPoints object.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "MapPointTableViewCell"
        let mapPoint = MapPoints.sharedInstance().mapPoints[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell
        
        cell.textLabel!.text = mapPoint.fullName
        return cell
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MapPoints.sharedInstance().mapPoints.count
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UIApplication.sharedApplication().openURL(NSURL(string: MapPoints.sharedInstance().mapPoints[indexPath.row].mediaURL)!)
    }
}