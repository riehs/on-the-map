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
    func loginToUdacity(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {

        //Get Session ID.
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)

        //API parameters.
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)

        //Initialize the session.
        let session = NSURLSession.sharedSession()

        //Initialize the task for getting the data.
        let task = session.dataTaskWithRequest(request) { data, response, error in

            if error != nil {
                completionHandler(success: false, errorString: error.description)
                }

            //The first five characters must be removed. They are included by Udacity for security purposes.
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))

            //Parse the data.
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary

            //Get the uerKey.
            if let userKey = parsedResult["account"]?.valueForKey("key") as? String {
                self.userKey = userKey
                completionHandler(success: true, errorString: nil)
            } else {
                completionHandler(success: false, errorString: "Incorrect username or password.")
            }
        }
        task.resume()
    }


    //Using the unique UserKey, get the user's first and last name.
    func setFirstNameLastName(completionHandler: (success: Bool, errorString: String?) -> Void) {

        //Initialize URL.
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(self.userKey)")!)

        //Initialize session.
        let session = NSURLSession.sharedSession()

        //Initialize the task for getting the data.
        let task = session.dataTaskWithRequest(request) { data, response, error in

            if error != nil {
                completionHandler(success: false, errorString: error.description)
            }

            //The first five characters must be removed. They are included by Udacity for security purposes.
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))

            //Parse the data.
            var parsingError: NSError? = nil
            let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary

            //Get the first name.
            if let firstName = parsedResult["user"]?.valueForKey("first_name") as? String {
                self.firstName = firstName
                } else {
                completionHandler(success: false, errorString: "Could not retrieve first or last name from Udacity.")
                    return
            }

            //Get the last name.
            if let lastName = parsedResult["user"]?.valueForKey("last_name") as? String {
                self.lastName = lastName
                } else {
                    completionHandler(success: false, errorString: "Could not retrieve first or last name from Udacity.")
                    return
                }
            completionHandler(success: true, errorString: nil)
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
