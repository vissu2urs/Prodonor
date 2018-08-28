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
     func locationManagerDidDenyAuthorization(locationManager: CLLocationManager)
     func locationManager(locationManager: CLLocationManager, didUpdateLocation location: CLLocation)
     func locationmanager(locationManager: CLLocationManager, failedWithError error: NSError)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    //MARK: Singleton
    static let sharedInstance = LocationManager()
    
    //MARK: Properties
    private var locationInstance: CLLocationManager?
    var delegate: LocationManagerDelegate?
    
    private override init() {
        super.init()
        self.checkValidityOfAuthorizationStatus(status: CLLocationManager.authorizationStatus())
        initiateLocationServices()
    }
    
    func initiateLocationServices() {
        locationInstance = CLLocationManager()
        locationInstance?.desiredAccuracy = kCLLocationAccuracyBest
        locationInstance?.requestAlwaysAuthorization()
        //locationInstance?.startUpdatingLocation()
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
        case .authorizedAlways:
            //do nothing
            break
        
        case .authorizedWhenInUse:
            self.showLocationSettingsAlert(havingTitle: NSLocalizedString("AlertTitle", comment: ""), andMessage: NSLocalizedString("LocationAuthorizationBackgroundAlert", comment: ""))
            break
            
        case .denied:
            self.showLocationSettingsAlert(havingTitle: NSLocalizedString("AlertTitle", comment: ""), andMessage: NSLocalizedString("LocationAuthorizationDeniedAlert", comment: ""))
            if let delegate = delegate {
                delegate.locationManagerDidDenyAuthorization(locationManager: locationInstance!)
            }
            break
            
        case .restricted:
            self.showLocationSettingsAlert(havingTitle: NSLocalizedString("AlertTitle", comment: ""), andMessage: NSLocalizedString("LocationAuthorizationRestrictedAlert", comment: ""))
            break
            
        default:
            break
        }
    }
    
    func showLocationSettingsAlert(havingTitle title: String, andMessage message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let settingsAction = UIAlertAction(title: NSLocalizedString("SettingsTitle", comment: ""), style: UIAlertActionStyle.default) { (action) -> Void in
            // open settings tab
            if UIApplication.shared.canOpenURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL) {
                UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: NSLocalizedString("CancelTitle", comment: ""), style: UIAlertActionStyle.cancel) { (action) -> Void in
            // repeat
            self.checkValidityOfAuthorizationStatus(status: CLLocationManager.authorizationStatus())
        }
        alertController.addAction(cancelAction)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        var rootViewController = appDelegate?.window?.rootViewController
        while ((rootViewController?.presentedViewController) != nil) {
            rootViewController = rootViewController?.presentedViewController
        }
        rootViewController?.present(alertController, animated: true, completion: { () -> Void in
            // do nothing
        })
    }
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last
        // call the delegate
        if let delegate = delegate {
            delegate.locationManager(locationManager: locationInstance!, didUpdateLocation: currentLocation!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // show alert that some error occoured
        if let delegate = delegate {
            delegate.locationmanager(locationManager: locationInstance!, failedWithError: error as NSError)
        }
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.checkValidityOfAuthorizationStatus(status: status)
    }
    
}
