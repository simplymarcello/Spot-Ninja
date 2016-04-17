//
//  BaseService.swift
//  Spot Ninja
//
//  Created by Ammar Karim on 3/15/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import Foundation
import Firebase

let Base_URL = "https://vivid-heat-8942.firebaseio.com"

let FIREBASE_URL = Firebase(url:Base_URL)

var CURRENT_USER: Firebase
{
    let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
    
    let currentUser = Firebase(url:"\(FIREBASE_URL)").childByAppendingPath("users").childByAppendingPath(userID)
    
    return currentUser!
}
