//
//  AddPinViewController.swift
//  On the Map
//
//  Created by Daniel Riehs on 3/22/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit
import MapKit

class AddPinViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var findButton: UIButton!
	@IBOutlet weak var addressField: UITextField!
	@IBOutlet weak var linkField: UITextField!
	@IBOutlet weak var submitButton: UIButton!
	@IBOutlet weak var workingMessage: UILabel!

	let LINK_FIELD = 1

	var coordinates: CLLocationCoordinate2D!


	@IBAction func tapCancelButton(_ sender: AnyObject) {
		dismiss(animated: true, completion: nil)
	}


    @IBAction func tapFindButton(_ sender: AnyObject) {
        findOnMap()
    }


	override func viewDidLoad() {
		super.viewDidLoad()

		linkField.tag = LINK_FIELD

		//This is required to add "http://" to the linkField text field when a user starts typing, and to call a findOnMap() when the return key is pressed.
		linkField.delegate = self

        //This is required to call the findOnMap() function when the return key is pressed.
        addressField.delegate = self

		//These items aren't revealed until the user successfully finds a location.
		mapView.isHidden = true
		submitButton.isHidden = true
		workingMessage.isHidden = true
	}


	//Calls the findOnMap() function when the keyboard return key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

		findOnMap()
		return true
    }


	func findOnMap() {

		//Indicates the geocoding is in process.
		workingMessage.isHidden = false

		let location = addressField.text
		let geocoder: CLGeocoder = CLGeocoder()

		//Geocodes the location.
		geocoder.geocodeAddressString(location!, completionHandler: { (placemarks, error) -> Void in

			//Returns an error if geocoding is unsuccessful.
			if ((error) != nil) {
				self.workingMessage.isHidden = true
				self.errorAlert("Invalid location", error: "Please try again.")
			}

				//If geocoding is successful, multiple locations may be returned in an array. Only the first location is used below.
				
			else if placemarks?[0] != nil {
				let placemark: CLPlacemark = placemarks![0]

				//Creats a coordinate and annotation.
				let coordinates: CLLocationCoordinate2D = placemark.location!.coordinate
				let pointAnnotation: MKPointAnnotation = MKPointAnnotation()
				pointAnnotation.coordinate = coordinates

				//Displays the map.
				self.mapView.isHidden = false

				//Places the annotation on the map.
				self.mapView?.addAnnotation(pointAnnotation)

				//Centers the map on the coordinates.
				self.mapView?.centerCoordinate = coordinates

				//Sets the zoom level on the map.
				self.mapView?.camera.altitude = 3000000;

				//Sets the coordinates parameter that is used if the user decides to submit this location.
				self.coordinates = coordinates

				//Items used to look for a location are hidden.
				self.workingMessage.isHidden = true
				self.findButton.isHidden = true
				self.addressField.isHidden = true

				//The keyboad is dismissed.
				self.addressField.resignFirstResponder()

				//This is necessary because the user may have moved his cursor to the linkField text field.
				self.linkField.resignFirstResponder()

				//The user can now submit the location.
				self.submitButton.isHidden = false

			}
		})
	}


	@IBAction func submitLocation(_ sender: AnyObject) {

		if validateUrl(linkField.text!) == false {
			errorAlert("Invalid URL", error: "Please try again.")
		} else {

			//Prevents user from submitting twice.
			submitButton.isHidden = true

			//Indicates that the app is working
			workingMessage.isHidden = false

			//Submits the new data point.
			MapPoints.sharedInstance().submitData(coordinates.latitude.description, longitude: coordinates.longitude.description, addressField: addressField.text!, link: linkField.text!) { (success, errorString) in
				if success {
					DispatchQueue.main.async(execute: {
						MapPoints.sharedInstance().needToRefreshData = true
						self.dismiss(animated: true, completion: nil)
					})
				} else {
					DispatchQueue.main.async(execute: {
						
						//If there is an error, the submit button is unhidden so that the user can try again.
						self.submitButton.isHidden = false
						self.workingMessage.isHidden = true
						self.errorAlert("Error", error: errorString!)
					})
				}
			}
		}
	}


	//Creates an Alert-style error message.
	func errorAlert(_ title: String, error: String) {
		let controller: UIAlertController = UIAlertController(title: title, message: error, preferredStyle: .alert)
		controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(controller, animated: true, completion: nil)
	}


	//Makes it easier for the user to enter a valid link.
	func textFieldDidBeginEditing(_ textField: UITextField) {

		if textField.tag == LINK_FIELD {
			textField.text = "http://"
		}
	}


	//Regular expression used for validating submitted URLs.
	func validateUrl(_ url: String) -> Bool {
		let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
		if url.range(of: pattern, options: .regularExpression) != nil {
			return true
		}
		return false
	}
}
