//
//  SensorActions.swift
//  SensorManager
//
//  Created by Bruce Collie on 01/09/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import CoreLocation

public class SensorActions {
    
    /// MARK : Location
    
    public class func locationAction(accuracy: LocationAccuracy) -> SensorAction {
        var ret : SensorAction
        switch(accuracy) {
            case .Fine:
                ret = {
                    LocationManager.sharedInstance.singleManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
                    LocationManager.sharedInstance.receivedCurrentLocation = {
                        (location : CLLocation) -> Void in
                        LocationLogger.logLocation(location, accuracyConfig: "LOCATION_ACCURACY_FINE")
                    }
                    LocationManager.sharedInstance.getCurrentLocation()
                }
            case .Coarse:
                ret = {
                    LocationManager.sharedInstance.singleManager.desiredAccuracy = kCLLocationAccuracyKilometer
                    LocationManager.sharedInstance.receivedCurrentLocation = {
                        (location : CLLocation) -> Void in
                        LocationLogger.logLocation(location, accuracyConfig: "LOCATION_ACCURACY_COARSE")
                    }
                    LocationManager.sharedInstance.getCurrentLocation()
                }
        }
        return ret
    }
    
    public class func startBackgroundLocationAction() -> TimedSensorAction {
        var block : SensorAction = {
            LocationManager.sharedInstance.updatedBackgroundLocation = {
                (locations : [CLLocation]) -> Void in
                LocationLogger.logLocations(locations, accuracyConfig: "LOCATION_ACCURACY_COARSE")
            }
            LocationManager.sharedInstance.startMonitoringInBackGround()
        }
        var time : NSTimeInterval = 0.0
        return (block, time)
    }
    
    public class func stopBackgroundLocationAction() -> SensorAction {
        return {
            LocationManager.sharedInstance.stopMonitoringInBackground()
            LocationManager.sharedInstance.updatedBackgroundLocation = nil
        }
    }
    
    /// MARK : Accelerometer
    
    public class func accelerometerAction(time : NSTimeInterval) -> SensorAction {
        var ret : SensorAction = {
            AccelerometerManager.sharedInstance.onReadFinished = {
                (data : [AccelerometerData]) -> Void in
                AccelerationLogger.logAccelerometerData(data, sampleLength: Int(time * 1000))
            }
            AccelerometerManager.sharedInstance.readForTime(time)
        }
        return ret
    }
    
}