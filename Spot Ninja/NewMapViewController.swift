//
//  NewMapViewController.swift
//  Spot Ninja
//
//  Created by Marcello & Ammar on 10/28/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import MapKit
import GeoFire


let geoFire = GeoFire(firebaseRef: FIREBASE_URL)


class NewMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBAction func LogoutAction(sender: AnyObject) {
        CURRENT_USER.unauth()
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "uid")
        let rootController = storyboard!.instantiateViewControllerWithIdentifier("welcome")
        self.presentViewController(rootController, animated: true, completion: nil)
    }
    
    var spots = Dictionary<String,CLLocation>()
    
    var pins = Dictionary<String,CustomPointAnnotationOpenSpot>()
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for _ in 0..<len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
    }
    

    @IBOutlet weak var map: MKMapView!
    
    var canClaim = false
    
    var canReport = false
    
    @IBOutlet var secondaryMenu: UIView!
    
    var destination = MKMapItem?()
    
    var manager: CLLocationManager!

    var latLocal:Double = 0.0
    var lonLocal:Double = 0.0
    
    let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
    }
    
// Still implimenting this
    
//    func GetToSpot() {
//        let place = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
//        destination = MKMapItem(placemark: place)
//        
//        let request = MKDirectionsRequest()
//        request.source = MKMapItem.mapItemForCurrentLocation()
//        request.destination = destination!
//        request.requestsAlternateRoutes = false
//        
//        let directions = MKDirections(request: request)
//        directions.calculateDirectionsWithCompletionHandler({ (response: MKDirectionsResponse?, error:NSError?) -> Void in
//            if error != nil {
//                // if error then handle it
//            } else {
//                self.showRoute(response!)
//            }
//        })
//    }
    
    func zoomInOnce() {
        let coordinate = CLLocationCoordinate2DMake(map.userLocation.coordinate.latitude, map.userLocation.coordinate.longitude)
        
        let latDelta:CLLocationDegrees = 0.02
        
        let lonDelta:CLLocationDegrees = 0.02
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
        
        self.map.setRegion(region, animated: true)
    }
    
    @IBAction func refreshMap(sender: AnyObject) {
        let annotationsToRemove = map.annotations
        self.map.removeAnnotations(annotationsToRemove)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        self.map.showsUserLocation = true
        
        if manager.respondsToSelector(#selector(CLLocationManager.requestAlwaysAuthorization)) == true {
            manager.requestAlwaysAuthorization()
            manager.startUpdatingLocation()
            let triggerTime = (Int64(NSEC_PER_SEC) * 3)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.zoomInOnce()
            })
        } else {
            self.zoomInOnce()
        }
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(NewMapViewController.action(_:)))
        
        uilpgr.minimumPressDuration = 1.0
        
        map.addGestureRecognizer(uilpgr)
        
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
            let touchPoint = gestureRecognizer.locationInView(self.map)
            
            let newCoordinate = self.map.convertPoint(touchPoint, toCoordinateFromView: self.map)
            
            let pinLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            CLGeocoder().reverseGeocodeLocation(pinLocation, completionHandler: { (placemarks, error) -> Void in
                
                var title = ""
                var house:String = ""
                var street:String = ""

                
                if (error == nil) {
                    if let p = placemarks?[0] {

                        if p.subThoroughfare != nil {
                            house = p.subThoroughfare!
                        }
                        if p.thoroughfare != nil {
                            street = p.thoroughfare!
                        }
                        if house != "" && street != "" {
                            title = "\(house) \(street)"
                        } else {
                            title = "Unknown Street"
                        }

                    }
                }
                
                let annotation = CustomPointAnnotationSpot()
                
                annotation.coordinate = newCoordinate
                
                annotation.title = title
                
                annotation.subtitle = self.randomStringWithLength(10) as String
                
                self.map.addAnnotation(annotation)
                
            })
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        let latitude  = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        latLocal = latitude
        lonLocal = longitude
        
        let center = CLLocation(latitude: latitude, longitude: longitude)
        
        let circleQuery = geoFire.queryAtLocation(center, withRadius: 0.2)
        
        circleQuery.observeEventType(.KeyEntered, withBlock: { (key: String!, location: CLLocation!) in
            let value = self.spots.updateValue(location, forKey: key)
            if value == nil {
                let annotation = CustomPointAnnotationOpenSpot()
                annotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
                annotation.title = "Open Spot!"
                annotation.subtitle=key
                self.map.addAnnotation(annotation)
                self.pins.updateValue(annotation, forKey: key)
            }

            
        })
        
        circleQuery.observeEventType(.KeyExited, withBlock: { (key: String!, location: CLLocation!) in
            let value = self.spots.indexForKey(key)
            if value != nil {
                let spot_to_remove = self.spots.indexForKey(key)
                let pin_to_remove = self.pins.indexForKey(key)
                self.map.removeAnnotation(self.pins[key]!)
                self.spots.removeAtIndex(spot_to_remove!)
                self.pins.removeAtIndex(pin_to_remove!)
            }
            
        })

        for (x, y) in self.spots {
            let distance = userLocation.distanceFromLocation(y)
            if distance > 200 {
                let spot_to_remove = self.spots.indexForKey(x)
                let pin_to_remove = self.pins.indexForKey(x)
                self.spots.removeAtIndex(spot_to_remove!)
                self.map.removeAnnotation(self.pins[x]!)
                self.pins.removeAtIndex(pin_to_remove!)
            }
        }

    }
    
    func indicateParkingLocation(latitude:Double, longitude:Double){
        
        geoFire.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: "\(randomStringWithLength(10))") { (error) in
            if (error == nil) {
                let alertController = UIAlertController(title: "Success", message:
                    "Spot successfully reported!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Whoops", message:
                    "Looks like something went wrong...", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }

        
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if annotation.isKindOfClass(MKUserLocation){
            return nil;
        }
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            if annotation.isMemberOfClass(CustomPointAnnotationOpenSpot){
                pinView!.pinTintColor = .greenColor()
            }else {
                pinView!.pinTintColor = .redColor()
            }
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            if annotation.isMemberOfClass(CustomPointAnnotationOpenSpot){
                pinView!.pinTintColor = .greenColor()
            }else {
                pinView!.pinTintColor = .redColor()
            }
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            canReport = false
            canClaim = false
            let userLocation = CLLocation(latitude: latLocal, longitude: lonLocal)
            let pinLocation = CLLocation(latitude: view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
            
            if view.annotation!.title! == "Open Spot!" && userLocation.distanceFromLocation(pinLocation) < 200.0 {
                canClaim = true
            }else if userLocation.distanceFromLocation(pinLocation) < 200.0 {
                canReport = true
            }
            
            let actionSheet = UIAlertController(title: "Project Spot", message: nil, preferredStyle: .ActionSheet)
            
            let reportAction = UIAlertAction(title: "Report Spot", style: .Default, handler: { action in
                self.reportSpot(pinLocation)
            })
            
            let claimAction = UIAlertAction(title: "Claim Spot", style: .Destructive, handler: { action in
                self.claimSpot(view.annotation!.subtitle!!)
                mapView.removeAnnotation(view.annotation!)
            })
            
            let canelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            
            if canReport {
                reportAction.enabled = true
            }else{
                reportAction.enabled = false
            }
            if canClaim {
                claimAction.enabled = true
            }else{
                claimAction.enabled = false
            }

            actionSheet.addAction(reportAction)
            actionSheet.addAction(claimAction)
            actionSheet.addAction(canelAction)

            self.presentViewController(actionSheet, animated: true, completion: nil)
            
        }
    }
    
    func reportSpot(pinLocation: CLLocation) {
        self.indicateParkingLocation(pinLocation.coordinate.latitude, longitude: pinLocation.coordinate.longitude)
    }
    
    func claimSpot(id: String) {
        geoFire.removeKey(id)
        let alertController = UIAlertController(title: "Success", message:
            "Spot successfully claimed!", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    class CustomPointAnnotationOpenSpot: MKPointAnnotation {
        var spotKey: String = ""
    }
    
    class CustomPointAnnotationSpot: MKPointAnnotation {
        var spotKey: String = ""
    }
}



