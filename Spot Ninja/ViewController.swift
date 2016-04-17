//
//  ViewController.swift
//  Spot Ninja
//
//  Created by Marcello & Ammar on 10/28/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Firebase
import CoreData

//@available(iOS 8.0, *)
class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var userName: UITextField!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var signUpText: UIButton!

    @IBOutlet weak var PrimaryText: UIButton!
    @IBOutlet weak var SecondaryText: UIButton!
    
    @IBOutlet var logInText: UIButton!
    
    @IBOutlet var registerLabel: UILabel!
    

    
    var signUpActive = false
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signUpButton(sender: AnyObject) {
        
        if userName.text == "" || password.text == "" {
            // display an alert if any field is empty
            displayAlert("Error in form", message: "Please enter a username and password")
            
        } else {
            // set up a Spinner that for the registration is processing
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            if signUpActive == true {
                
                let usernames = userName.text
                let passwords = password.text
            
                //Firebase SignUp
                FIREBASE_URL.createUser(usernames, password: passwords,
                    withValueCompletionBlock: { (error, result) -> Void in
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        if error != nil {
                            // There was an error creating the account
                            print("You played yoself")
                            print(error)
                        } else {
                           
                            FIREBASE_URL.authUser(usernames, password: passwords, withCompletionBlock: { (error, authData) -> Void in
                                
                                if error == nil {
                                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "uid")
                                    print("account Created :)")
                                    
                                } else {
                                    print(error)
                                }
                                
                            
                            })
                            let uid = result["uid"] as? String
                            
                            print("Successfully created user account with uid: \(uid)")
                            let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
                            self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)

                        }
                })
                
            } else {
                //Firebase LogIn
                FIREBASE_URL.authUser(userName.text!, password: password.text!,
                    withCompletionBlock: { error, authData in
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        if error != nil {
                            // There was an error logging in to this account
                            print("You played yoself")
                            print(error)
                            
                        } else {
                            // We are now logged in
                            NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "uid")
                            let mapViewControllerObejct = self.storyboard?.instantiateViewControllerWithIdentifier("logined")
                            self.presentViewController(mapViewControllerObejct!, animated: true, completion: nil)
                            
                        }
                })
            }
        }
        
    }
    
    @IBAction func SecondaryButton(sender: AnyObject) {
        if signUpActive == true {
            signUpText.setTitle("Sign Up", forState: UIControlState.Normal)
            registerLabel.text = "Already registered?"
            logInText.setTitle("Login", forState: UIControlState.Normal)
            signUpActive = true
        } else {
            signUpText.setTitle("Login", forState: UIControlState.Normal)
            registerLabel.text = "Not registered?"
            logInText.setTitle("SignUp", forState: UIControlState.Normal)
            signUpActive = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        userName.delegate = self
        password.delegate = self
    }
    
}
