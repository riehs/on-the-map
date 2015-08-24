//
//  StudentInformation.swift
//  On the Map
//
//  Created by Daniel Riehs on 3/22/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import Foundation

struct StudentInformation {

	var fullName = ""
	var latitude = 0.0
	var longitude = 0.0
	var mediaURL = ""
	
	//The if statements are necessary because the Parse data may not contain all keys.
	init(dictionary: [String : AnyObject]) {
		
		var firstName = ""
		var lastName = ""
		
		if let first = dictionary["firstName"] as? String {
			firstName = first
		}
		if let last = dictionary["lastName"] as? String {
			lastName = last
		}
		
		fullName = firstName + " " + lastName
		
		if let lat = dictionary["latitude"] as? Double {
			latitude = lat
		}
		if let long = dictionary["longitude"] as? Double {
			longitude = long
		}
		if let media = dictionary["mediaURL"] as? String {
			mediaURL = media
		}
	}
}