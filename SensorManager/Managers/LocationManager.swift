//
//  LocationManager.swift
//  SensorManager
//
//  Created by Bruce Collie on 27/08/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import CoreLocation

public class LocationManager : NSObject, CLLocationManagerDelegate {
    
    var singleManager : CLLocationManager = CLLocationManager()
    var backgroundManager : CLLocationManager = CLLocationManager()
    
    var currentLocation : CLLocation?
    var backgroundLocations : [CLLocation] = []
    
    private var seekingLocation : Bool = false
    
    public class var sharedInstance : LocationManager {
    struct Static {
        static let manager : LocationManager = LocationManager()
        }
        return Static.manager;
    }
    
    private override init() {
        super.init()
        
        singleManager.delegate = self
        singleManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        singleManager.distanceFilter = kCLDistanceFilterNone
        singleManager.pausesLocationUpdatesAutomatically = false
        
        backgroundManager.delegate = self
        
        //This presents the iOS system dialog to ask to use the device location - will be presented only once as long as they accept it.
        //TODO: Need to remember if the user says no, then ask again later.
        singleManager.requestWhenInUseAuthorization()
    }
    
    ///This method is called when the device's most recent location is found.
    public var receivedCurrentLocation : (CLLocation -> Void)?
    
    ///This method is called with the array of all background locations so far each time the device location is updated in the background.
    public var updatedBackgroundLocation : ([CLLocation] -> Void)?
    
    ///Asks the location manager to provide the most recent known location of the device. This location is then passed to the receivedCurrentLocation callback, and sets the currentLocation field on the sharedInstance. Uses fine-grained (i.e. the best accuracy available to the device).
    public func getCurrentLocation() {
        seekingLocation = true
        singleManager.startUpdatingLocation()
    }
    
    ///Clears the array of background locations that have already been retrieved
    public func startMonitoringInBackGround() {
        backgroundLocations = []
        backgroundManager.startMonitoringSignificantLocationChanges()
    }
    
    public func stopMonitoringInBackground() {
        println("Should stop finding location.")
        backgroundManager.stopMonitoringSignificantLocationChanges()
    }
    
    public func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if manager === singleManager {
            singleManager.stopUpdatingLocation()
            
            if seekingLocation {
                
                if let callback = receivedCurrentLocation {
                    callback(locations.last! as! CLLocation)
                }
                
                currentLocation = locations.last! as? CLLocation
                println("New current location: \(currentLocation!.coordinate.latitude), \(currentLocation!.coordinate.longitude)")
            }
            
            seekingLocation = false
            
            //Need to stop updating the location once we have a fix so that the location services arrow goes away.
        } else if manager === backgroundManager {
            for item : AnyObject in locations {
                if let tryLocation = item as? CLLocation {
                    println("New background location: \(tryLocation.coordinate.latitude), \(tryLocation.coordinate.longitude)")
                    backgroundLocations.append(tryLocation)
                }
            }
            
            if let callback = updatedBackgroundLocation {
                callback(backgroundLocations)
            }
        }
    }
    
    public func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Failed to get location: \(error.localizedDescription)")
    }
    
}

public enum LocationAccuracy : String {
    
    case Fine = "LOCATION_ACCURACY_FINE"
    case Coarse = "LOCATION_ACCURACY_COARSE"
    
}
