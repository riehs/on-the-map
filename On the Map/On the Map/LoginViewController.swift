//
//  LoginViewController.swift
//  On the Map
//
//  Created by Daniel Riehs on 3/22/15.
//  Copyright (c) 2015 Daniel Riehs. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!

	//This label displays user instructions, errors, and a "Connecting..." message.
	@IBOutlet weak var errorLabel: UILabel!

	@IBOutlet weak var loginButton: UIButton!


	@IBAction func tapSignUpButton(_ sender: AnyObject) {
		UIApplication.shared.openURL(URL(string: "https://www.udacity.com/account/auth#!/signup")!)
	}


	//Tapping the loginButton fetches a userKey from Udacity, fetches a firstName and a lastName from Udacity, and then fetches student information from Parse. Only when all three steps are complete is the completeLogin function called to segue to the map.
	@IBAction func tapLoginButton(_ sender: AnyObject) {

		loginButton.isEnabled = false
		errorLabel.text = "Connecting..."

		//Basic error check before sending the credentials to Udacity.
		if (usernameTextField.text == "" || passwordTextField.text == "") {
			displayError("Enter a username and password.")

		//Fetching userKey from Udacity.
		} else {
			UdacityLogin.sharedInstance().loginToUdacity(username: usernameTextField.text!, password: passwordTextField.text!) { (success, errorString) in
				if success {

					//Fetching first and last name from Udacity.
					UdacityLogin.sharedInstance().setFirstNameLastName() { (success, errorString) in
						if success {

							//Fetching student information from Parse.
							MapPoints.sharedInstance().fetchData() { (success, errorString) in
								if success {
									self.completeLogin()
								} else {
									self.displayError(errorString)
								}
							}
						} else {
							self.displayError(errorString)
						}
					}
				} else {
					self.displayError(errorString)
				}
			}
		}
	}


	//Complete the login and present the first navigation controller.
	func completeLogin() {
		DispatchQueue.main.async(execute: {
			let controller = self.storyboard!.instantiateViewController(withIdentifier: "StudentsNavigationController") as! UINavigationController
			self.present(controller, animated: true, completion: nil)
		})
	}


	//Display error messages returned from any of the completion handlers.
	func displayError(_ errorString: String?) {
		DispatchQueue.main.async(execute: {
			if let errorString = errorString {
				self.errorLabel.text = errorString
				//The login button in re-enabled so that the user can try again.
				self.loginButton.isEnabled = true
			}
		})
	}
}

