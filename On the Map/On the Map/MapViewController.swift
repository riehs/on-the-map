//
//  MapViewController.swift
//  On the Map
//
//  Created by Daniel Riehs on 3/22/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        
        //Sets the map zoom.
        self.mapView?.camera.altitude = 50000000;
        
        //Sets the center of the map.
        self.mapView?.centerCoordinate = CLLocationCoordinate2D(latitude: -3.831239, longitude: -78.183406)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        //Adding a link to the annotation requires making the mapView a delegate of MKMapView.
        self.mapView.delegate = self
        
        for result in MapPoints.sharedInstance().mapPoints {
            
            //Creates an annotation and coordinate.
            var annotation = MKPointAnnotation()
            var location = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
            
            //Sets the coordinates of the annotation.
            annotation.setCoordinate(location)
            
            //Adds a student name and URL to the annotation.
            annotation.title = result.firstName + " " + result.lastName
            annotation.subtitle = result.mediaURL
            
            //Adds the annotation to the map.
            self.mapView.addAnnotation(annotation)
        }
    }
    
    
    //Opens the mediaURL in Safari when the annotation info box is tapped.
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        UIApplication.sharedApplication().openURL(NSURL(string: view.annotation.subtitle!)!)
    }
    
    
    //Adds a "callout" to the annotation info box so that it can be tapped to access the mediaURL.
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MapAnnotation")
        view.canShowCallout = true
        view.calloutOffset = CGPoint(x: -5, y: 5)
        view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIView
        return view
    }
}