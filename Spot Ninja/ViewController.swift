//
//  ViewController.swift
//  Spot Ninja
//
//  Created by Marcello & Ammar on 10/28/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Firebase

//@available(iOS 8.0, *)
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    let gradient: CAGradientLayer = CAGradientLayer()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func textFieldShouldReturn(userText: UITextField) -> Bool {
        userText.resignFirstResponder()
        return true;
    }
    
    override func viewDidLoad() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        super.viewDidLoad()
        gradient.frame = self.view.bounds
        gradient.colors = [UIColorFromRGB(0x1D77EF).CGColor, UIColorFromRGB(0x81F3FD).CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        print("ViewDidApper")
        if CURRENT_USER != nil {
            self.performSegueWithIdentifier("SignInSegue", sender: nil)
        }
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    @IBAction func SignInButton(sender: AnyObject) {
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        
        if email == "" || password == "" {
            self.displayAlert("Error", message: "Please enter your email and password")
        } else {
            // set up a Spinner that for the registration is processing
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            //Firebase LogIn
            FIREBASE_URL.authUser(email, password: password, withCompletionBlock: { error, authData in
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                if error != nil {
                    if let errorCode = FAuthenticationError(rawValue: error.code) {
                        switch (errorCode) {
                        case .UserDoesNotExist:
                            self.displayAlert("Invalid user", message: "User is invalid")
                        case .InvalidEmail:
                            self.displayAlert("Invalid email", message: "Email address is invalid")
                        case .InvalidPassword:
                            self.displayAlert("Invalid password", message: "Password is invalid")
                        default:
                            self.displayAlert("Sign in Error", message: "Unable to sign in at this time")
                        }
                    }
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "uid")
                    self.performSegueWithIdentifier("SignInSegue", sender: nil)
                }
            })
        }
    }

}
