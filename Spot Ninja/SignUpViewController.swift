//
//  SignUpViewController.swift
//  Spot Ninja
//
//  Created by Marcello Martins on 4/20/16.
//  Copyright © 2016 Marcello Martins. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBAction func SignUpButtonAction(sender: AnyObject) {
        let email = self.EmailTextField.text
        let password = self.PasswordTextField.text
        let confirm = self.ConfirmPasswordTextField.text
        
        
        if email == "" || password == "" || confirm == "" {
            displayAlert("Input Error", message: "All the information fields must be filled out")
        }
        else if !isValidEmail(email!) {
            displayAlert("Email Error", message: "Email must be valid email address")
        }
        else if password?.characters.count < 4 {
            displayAlert("Password Error", message: "Password must be at least 5 characters long")
        }
        else if password != confirm {
            displayAlert("Password Error", message: "Passwords don't match")
        }else {
            // set up a Spinner that for the registration is processing
            activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(activityIndicator)
            activityIndicator.startAnimating()
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
            
            FIREBASE_URL.createUser(email, password: password, withValueCompletionBlock: { (error, result) -> Void in
                if error != nil {
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    self.displayAlert("Sign Up Error", message: "\(error)")
                    self.performSegueWithIdentifier("ErrorSegue", sender: nil)
                } else {
                    FIREBASE_URL.authUser(email, password: password, withCompletionBlock: { (error, authData) -> Void in
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        if error == nil {
                            NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: "uid")
                            self.performSegueWithIdentifier("SignUpSegue", sender: nil)
                        } else {
                            self.displayAlert("Sign In Error", message: "\(error)")
                            self.performSegueWithIdentifier("ErrorSegue", sender: nil)
                        }
                    })
                }
            })
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
