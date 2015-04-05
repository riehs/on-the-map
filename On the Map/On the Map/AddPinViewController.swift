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
    
    
    var coordinates: CLLocationCoordinate2D!
    

    @IBAction func tapCancelButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //This is required to add "http://" to the linkField text field when a user starts typing.
        self.linkField.delegate = self
        
        //These items aren't revealed until the user successfully finds a location.
        self.mapView.hidden = true
        self.submitButton.hidden = true
        self.workingMessage.hidden = true
    }
    
    
    @IBAction func findOnMap(sender: AnyObject) {
        
        //Indicates the geocoding is in process.
        self.workingMessage.hidden = false
        
        let location = self.addressField.text
        var geocoder: CLGeocoder = CLGeocoder()
        
        //Geocodes the location.
        geocoder.geocodeAddressString(location, { (placemarks, error) -> Void in
            
            //Returns an error if geocoding is unsuccessful.
            if ((error) != nil) {
                self.workingMessage.hidden = true
                self.errorAlert("Invalid location", error: "Please try again.")
            }
                
                //If geocoding is successful, multiple locations may be returned in an array. Only the first location is used below.
            else if let placemark = placemarks?[0] as? CLPlacemark {
                var placemark: CLPlacemark = placemarks[0] as CLPlacemark
                
                //Creats a coordinate and annotation.
                var coordinates: CLLocationCoordinate2D = placemark.location.coordinate
                var pointAnnotation: MKPointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = coordinates
                
                //Displays the map.
                self.mapView.hidden = false
                
                //Places the annotation on the map.
                self.mapView?.addAnnotation(pointAnnotation)
                
                //Centers the map on the coordinates.
                self.mapView?.centerCoordinate = coordinates
                
                //Sets the zoom level on the map.
                self.mapView?.camera.altitude = 3000000;
                
                //Sets the coordinates parameter that is used if the user decides to submit this location.
                self.coordinates = coordinates
                
                //Items used to look for a location are hidden.
                self.workingMessage.hidden = true
                self.findButton.hidden = true
                self.addressField.hidden = true
                
                //The keyboad is dismissed.
                self.addressField.resignFirstResponder()
                
                //This is necessary because the user may have moved his cursor to the linkField text field.
                self.linkField.resignFirstResponder()
                
                //The user can now submit the location.
                self.submitButton.hidden = false
                
            }
        })
    }
    
    
    @IBAction func submitLocation(sender: AnyObject) {
        
        if validateUrl(self.linkField.text) == false {
            errorAlert("Invalid URL", error: "Please try again.")
        } else {
            
            //Prevents user from submitting twice.
            self.submitButton.hidden = true
            
            //Indicates that the app is working
            self.workingMessage.hidden = false
            
            //Submits the new data point.
            MapPoints.sharedInstance().submitData(self.coordinates.latitude.description, longitude: self.coordinates.longitude.description, addressField: self.addressField.text, link: self.linkField.text) { (success, errorString) in
                if success {
                    dispatch_async(dispatch_get_main_queue(), {
                        MapPoints.sharedInstance().needToRefreshData = true
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        //If there is an error, the submit button is unhidden so that the user can try again.
                        self.submitButton.hidden = false
                        self.workingMessage.hidden = true
                        self.errorAlert("Error", error: errorString!)
                    })
                }
            }
        }
    }
    
    
    //Creates an Alert-style error message.
    func errorAlert(title: String, error: String) {
        let controller: UIAlertController = UIAlertController(title: title, message: error, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    //Makes it easier for the user to enter a valid link.
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = "http://"
    }
    
    
    //Regular expression used for validating submitted URLs.
    func validateUrl(url: String) -> Bool {
        let pattern = "^(https?:\\/\\/)([a-zA-Z0-9_\\-~]+\\.)+[a-zA-Z0-9_\\-~\\/\\.]+$"
        if let match = url.rangeOfString(pattern, options: .RegularExpressionSearch){
            return true
        }
        return false
    }
}