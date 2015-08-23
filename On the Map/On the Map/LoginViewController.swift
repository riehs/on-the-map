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


    @IBAction func tapSignUpButton(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }


    //Tapping the loginButton fetches a userKey from Udacity, fetches a firstName and a lastName from Udacity, and then fetches student information from Parse. Only when all three steps are complete is the completeLogin function called to segue to the map.
    @IBAction func tapLoginButton(sender: AnyObject) {

        self.loginButton.enabled = false
        self.errorLabel.text = "Connecting..."

        //Basic error check before sending the credentials to Udacity.
        if (self.usernameTextField.text == "" || self.passwordTextField.text == "") {
            displayError("Enter a username and password.")

        //Fetching userKey from Udacity.
        } else {
            UdacityLogin.sharedInstance().loginToUdacity(self.usernameTextField.text, password: self.passwordTextField.text) { (success, errorString) in
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
        dispatch_async(dispatch_get_main_queue(), {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("StudentsNavigationController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }


    //Display error messages returned from any of the completion handlers.
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.errorLabel.text = errorString
                //The login button in re-enabled so that the user can try again.
                self.loginButton.enabled = true
            }
        })
    }
}

