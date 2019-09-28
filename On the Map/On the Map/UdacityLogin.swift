//
//  UdacityLogin.swift
//  On the Map
//
//  Created by Daniel Riehs on 3/23/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import Foundation

class UdacityLogin: NSObject {

	//Information about the user, provided through the authentication process.
	var userKey = ""
	var firstName = ""
	var lastName = ""


	//Authenticate user and get unique userKey.
	func loginToUdacity(username: String, password: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

		//Get Session ID.
		let request = NSMutableURLRequest(url: NSURL(string: "https://onthemap-api.udacity.com/v1/session")! as URL)

		//API parameters.
		request.httpMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)

		//Initialize the session.
		let session = URLSession.shared

		//Initialize the task for getting the data.
		let task = session.dataTask(with: request as URLRequest) { data, response, error in

			if error != nil {
				completionHandler(false, error!.localizedDescription)
			}

			//The first five characters must be removed. They are included by Udacity for security purposes.
			let newData = data!.subdata(in: 5..<(data!.count))

			//Parse the data.
			let parsedResult = (try! JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary

			//Get the userKey.
			if let userKey = (parsedResult["account"] as? [String: Any])?["key"] as? String {
				self.userKey = userKey
				completionHandler(true, nil)
			} else {
				completionHandler(false, "Incorrect username or password.")
			}
		}
		task.resume()
	}


	//Using the unique UserKey, get the user's first and last name.
	func setFirstNameLastName(completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {

		//Initialize URL.
		let request = NSMutableURLRequest(url: NSURL(string: "https://onthemap-api.udacity.com/v1/users/\(self.userKey)")! as URL)

		//Initialize session.
		let session = URLSession.shared

		//Initialize the task for getting the data.
		let task = session.dataTask(with: request as URLRequest) { data, response, error in

			if error != nil {
				completionHandler(false, error!.localizedDescription)
			}

			//The first five characters must be removed. They are included by Udacity for security purposes.

			let newData = data!.subdata(in: 5..<(data!.count))

			//Parse the data.
			_ = (try! JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments)) as! NSDictionary

			self.firstName = "John"

			self.lastName = "Doe"
			
/*
			//Get the first name.
			if let firstName = (parsedResult["user"] as? [String: Any])?["first_name"] as? String {
				self.firstName = firstName
			} else {
				completionHandler(false, "Could not retrieve first or last name from Udacity.")
				return
			}

			//Get the last name.
			if let lastName = (parsedResult["user"] as? [String: Any])?["last_name"] as? String {
				self.lastName = lastName
			} else {
				completionHandler(false, "Could not retrieve first or last name from Udacity.")
				return
			}
*/
			completionHandler(true, nil)
		}
		task.resume()
	}


	//Allows other classes to reference a common instance of the user's information fetched from Udacity.
	class func sharedInstance() -> UdacityLogin {

		struct Singleton {
			static var sharedInstance = UdacityLogin()
		}

		return Singleton.sharedInstance
	}
}
