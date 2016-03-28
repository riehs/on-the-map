//
//  MapViewController.swift
//  On the Map
//
//  Created by Daniel Riehs on 3/22/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, ReloadableTab {


	@IBOutlet weak var mapView: MKMapView!


	override func viewDidLoad() {
		super.viewDidLoad()

		//Sets the map zoom.
		mapView?.camera.altitude = 50000000;

		//Sets the center of the map.
		mapView?.centerCoordinate = CLLocationCoordinate2D(latitude: -3.831239, longitude: -78.183406)

		//Adding a link to the annotation requires making the mapView a delegate of MKMapView.
		mapView.delegate = self

		//Draws the annotations on the map.
		reloadViewController()
	}


	//Opens the mediaURL in Safari when the annotation info box is tapped.
	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		UIApplication.sharedApplication().openURL(NSURL(string: view.annotation!.subtitle!!)!)
	}


	//Adds a "callout" to the annotation info box so that it can be tapped to access the mediaURL.
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "MapAnnotation")
		view.canShowCallout = true
		view.calloutOffset = CGPoint(x: -5, y: 5)
		view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
		return view
	}


	//Required to conform to the ReloadableTab protocol.
	func reloadViewController() {
		for result in MapPoints.sharedInstance().mapPoints {

			//Creates an annotation and coordinate.
			let annotation = MKPointAnnotation()
			let location = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)

			//Sets the coordinates of the annotation.
			annotation.coordinate = location

			//Adds a student name and URL to the annotation.
			annotation.title = result.fullName
			annotation.subtitle = result.mediaURL

			//Adds the annotation to the map.
			mapView.addAnnotation(annotation)
		}
	}
}
