////
////  ShowRouteViewController.swift
////  Spot Ninja
////
////  Created by Marcello & Ammar on 10/28/15.
////  Copyright © 2015 Parse. All rights reserved.
////
//
//import UIKit
//import MapKit
//
//class ShowRouteViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
//
//    @IBOutlet weak var map: MKMapView!
//    var destination = MKMapItem?()
//    var manager: CLLocationManager!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        map.delegate = self
//        manager = CLLocationManager()
//        manager.delegate = self
//        manager.desiredAccuracy = kCLLocationAccuracyBest
//        
//        self.map.showsUserLocation = true
//        // **********************************************************************
//        // code for route direction
//        let latitude  = map.userLocation.coordinate.latitude
//        let longitude = map.userLocation.coordinate.longitude
//        
//        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
//        
//        let latDelta:CLLocationDegrees = 0.05
//        
//        let lonDelta:CLLocationDegrees = 0.05
//        
//        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
//        
//        let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate, span)
//        
//        self.map.setRegion(region, animated: true)
//        
//        let annotation = MKPointAnnotation()
//        
//        annotation.coordinate = coordinate
//        
//        self.map.addAnnotation(annotation)
//        
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
//        // **********************************************************************
//
//    }
//    
//    // **********************************************************************
//    func showRoute(response:MKDirectionsResponse) {
//        for route in response.routes {
//            map.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
//            
//            for step in route.steps {
//                print(step.instructions)
//                
//            }
//        }
////                let region = MKCoordinateRegionMakeWithDistance(userLocation!.coordinate, 2000, 2000)
////                map.setRegion(region, animated: true)
//    }
//    
//    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
//        let renderer = MKPolylineRenderer(overlay: overlay)
//        renderer.strokeColor = UIColor.blueColor()
//        renderer.lineWidth = 5.0
//        return renderer
//    }
//    
//    // **********************************************************************
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
