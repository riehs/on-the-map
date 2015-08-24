//
//  MapPoints.swift
//  On the Map
//
//  Created by Daniel Riehs on 3/23/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import Foundation

class MapPoints: NSObject {


	//The Parse Application ID and API Key are available in the "On the Map Project Details" section of Udacity.com's "iOS Networking with Swift" course.
	let ParseID: String = "SET APPLICATION ID HERE."
	let ParseAPIKey: String = "SET API KEY HERE."


	//Each point on the map is a StudentInformation object. They are stored in this array.
	var mapPoints = [StudentInformation]()


	//This will be set to true when a new pin is submitted to Parse.
	var needToRefreshData = false


	//Get student information from Parse.
	func fetchData(completionHandler: (success: Bool, errorString: String?) -> Void) {

		let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
		request.addValue(self.ParseID, forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue(self.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

		//Initialize session.
		let session = NSURLSession.sharedSession()

		//Initialize task for data retrieval.
		let task = session.dataTaskWithRequest(request) { data, response, error in
			if error != nil {
				completionHandler(success: false, errorString: error.description)
			}

			//Parse the data.
			var parsingError: NSError? = nil
			let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary

			if let error = parsingError {
				completionHandler(success: false, errorString: error.description)

			} else {
				if let results = parsedResult["results"] as? [[String : AnyObject]] {

					//Clear existing data from the mapPoints object.
					self.mapPoints.removeAll(keepCapacity: true)

					//Re-populate the mapPoints object with refreshed data.
					for result in results {
						self.mapPoints.append(StudentInformation(dictionary: result))
					}

					//Setting this flag to true lets the TabViewController know that the views need to be reloaded.
					self.needToRefreshData = true

					completionHandler(success: true, errorString: nil)
				} else {
					completionHandler(success: false, errorString: "Could not find results in \(parsedResult)")
				}
			}

		}
		task.resume()
	}


	//Submit a student information node to Parse.
	func submitData(latitude: String, longitude: String, addressField: String, link: String, completionHandler: (success: Bool, errorString: String?) -> Void) {

		let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
		request.HTTPMethod = "POST"
		request.addValue(self.ParseID, forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue(self.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")

		//API Parameters.
		request.HTTPBody = "{\"uniqueKey\": \"\(UdacityLogin.sharedInstance().userKey)\", \"firstName\": \"\(UdacityLogin.sharedInstance().firstName)\", \"lastName\": \"\(UdacityLogin.sharedInstance().lastName)\",\"mapString\": \"\(addressField)\", \"mediaURL\": \"\(link)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)

		//Initialize session.
		let session = NSURLSession.sharedSession()

		//Initialize task for data retrieval.
		let task = session.dataTaskWithRequest(request) { data, response, error in

		if error != nil {
			completionHandler(success: false, errorString: "Failed to submit data.")
		} else {
			completionHandler(success: true, errorString: nil)
			}

		}
		task.resume()


		/*
		// Code for deleting a record - Not currently in use.

		let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation/UniqueObjectId")!)
		request.HTTPMethod = "DELETE"
		request.addValue(self.ParseID, forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue(self.ParseAPIKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(request) { data, response, error in
			if error != nil {
				completionHandler(success: false, errorString: "Failed to submit data.")
			} else {
				completionHandler(success: true, errorString: nil)
			}
		}
		task.resume()

		// End code for deleting.
		*/


	}


	//Allows other classes to reference a common instance of the mapPoints array.
	class func sharedInstance() -> MapPoints {

		struct Singleton {
			static var sharedInstance = MapPoints()
		}
		return Singleton.sharedInstance
	}
}
