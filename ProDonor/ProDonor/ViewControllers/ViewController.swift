//
//  ViewController.swift
//  ProDonor
//
//  Created by Varun on 30/08/16.
//  Copyright © 2016 DC. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, LocationManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ProDonor: Creation of dev branch.")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        LocationManager.sharedInstance.delegate = self
        LocationManager.sharedInstance.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(locationManager: CLLocationManager, didUpdateLocation location: CLLocation) {
        print("LATITUDE: \(location.coordinate.latitude); LONGITUDE: \(location.coordinate.longitude); TIMESTAMP: \(location.timestamp)")
    }
    
    func locationmanager(locationManager: CLLocationManager, failedWithError error: NSError) {
        print("LOCATION MANAGER FAILED: \(error)")
    }
    
    func locationManagerDidDenyAuthorization(locationManager: CLLocationManager) {
        print("Location Manager did deny authorization")
    }
}

