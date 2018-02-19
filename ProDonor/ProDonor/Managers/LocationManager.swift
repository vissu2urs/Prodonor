//
//  LocationManager.swift
//  ProDonor
//
//  Created by Varun on 30/08/16.
//  Copyright © 2016 DC. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

@objc protocol LocationManagerDelegate {
    optional func locationManagerDidDenyAuthorization(locationManager: CLLocationManager)
    optional func locationManager(locationManager: CLLocationManager, didUpdateLocation location: CLLocation)
    optional func locationmanager(locationManager: CLLocationManager, failedWithError error: NSError)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    //MARK: Singleton
    static let sharedInstance = LocationManager()
    
    //MARK: Properties
    private var locationInstance: CLLocationManager?
    var delegate: LocationManagerDelegate?
    
    private override init() {
        super.init()
        self.checkValidityOfAuthorizationStatus(CLLocationManager.authorizationStatus())
        initiateLocationServices()
    }
    
    func initiateLocationServices() {
        locationInstance = CLLocationManager()
        locationInstance?.requestAlwaysAuthorization()
        locationInstance?.delegate = self
    }
    
    func startUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationInstance?.startMonitoringSignificantLocationChanges()
        }
    }
    
    func stopUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationInstance?.startMonitoringSignificantLocationChanges()
        }
    }
    
    func checkValidityOfAuthorizationStatus(status: CLAuthorizationStatus) {
        switch (status) {
        case .AuthorizedAlways:
            //do nothing
            break
        
        case .AuthorizedWhenInUse:
            self.showLocationSettingsAlert(havingTitle: NSLocalizedString("AlertTitle", comment: ""), andMessage: NSLocalizedString("LocationAuthorizationBackgroundAlert", comment: ""))
            break
            
        case .Denied:
            self.showLocationSettingsAlert(havingTitle: NSLocalizedString("AlertTitle", comment: ""), andMessage: NSLocalizedString("LocationAuthorizationDeniedAlert", comment: ""))
            if let delegate = delegate {
                delegate.locationManagerDidDenyAuthorization?(locationInstance!)
            }
            break
            
        case .Restricted:
            self.showLocationSettingsAlert(havingTitle: NSLocalizedString("AlertTitle", comment: ""), andMessage: NSLocalizedString("LocationAuthorizationRestrictedAlert", comment: ""))
            break
            
        default:
            break
        }
    }
    
    func showLocationSettingsAlert(havingTitle title: String, andMessage message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let settingsAction = UIAlertAction(title: NSLocalizedString("SettingsTitle", comment: ""), style: UIAlertActionStyle.Default) { (action) -> Void in
            // open settings tab
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: UIApplicationOpenSettingsURLString)!) {
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("CancelTitle", comment: ""), style: UIAlertActionStyle.Cancel) { (action) -> Void in
            // repeat
            self.checkValidityOfAuthorizationStatus(CLLocationManager.authorizationStatus())
        }
        alertController.addAction(cancelAction)
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        var rootViewController = appDelegate?.window?.rootViewController
        while ((rootViewController?.presentedViewController) != nil) {
            rootViewController = rootViewController?.presentedViewController
        }
        rootViewController?.presentViewController(alertController, animated: true, completion: { () -> Void in
            // do nothing
        })
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        // call the delegate
        if let delegate = delegate {
            delegate.locationManager?(locationInstance!, didUpdateLocation: currentLocation!)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // show alert that some error occoured
        if let delegate = delegate {
            delegate.locationmanager?(locationInstance!, failedWithError: error)
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.checkValidityOfAuthorizationStatus(status)
    }
    
}