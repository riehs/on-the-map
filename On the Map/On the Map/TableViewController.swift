//
//  TableViewController.swift
//  On the Map
//
//  Created by Daniel Riehs on 3/22/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, ReloadableTab {


	//The data for the table cells is stored in the mapPonts array in the sharedInstace of the MapPoints object.
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cellReuseIdentifier = "MapPointTableViewCell"
		let mapPoint = MapPoints.sharedInstance().mapPoints[(indexPath as NSIndexPath).row]
		let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)

		cell!.textLabel!.text = mapPoint.fullName
		return cell!
	}


	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return MapPoints.sharedInstance().mapPoints.count
	}


	//Opens the mediaURL in Safari when a table cell is tapped.
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		UIApplication.shared.openURL(URL(string: MapPoints.sharedInstance().mapPoints[(indexPath as NSIndexPath).row].mediaURL)!)
	}


	//Required to conform to the ReloadableTab protocol.
	func reloadViewController() {
		tableView.reloadData()
	}
}
