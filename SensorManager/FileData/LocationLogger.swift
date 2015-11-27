//
//  LocationLogger.swift
//  SensorManager
//
//  Created by Bruce Collie on 02/09/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON

public class LocationLogger {
    
    public class func logLocation(location : CLLocation, accuracyConfig: String) {
        var formatter = NSDateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("HH:mm:ss:SSS dd MM yyyy Z z")
        formatter.locale = NSLocale(localeIdentifier: "US")
        
        var dict : [String : JSONValue] = [
            "time" : JSONValue.JNumber(NSNumber(longLong: Int64(location.timestamp.timeIntervalSince1970 * 1000.0))),
            "senseStartTime" : JSONValue.JString(formatter.stringFromDate(location.timestamp)),
            "speed" : JSONValue.JNumber(location.speed < 0.0 ? 0.0 : location.speed),
            "sensorType" : JSONValue.JString("Location"),
            "bearing" : JSONValue.JNumber(location.course < 0.0 ? 0.0 : location.course),
            "longitude" : JSONValue.JNumber(location.coordinate.longitude),
            "latitude" : JSONValue.JNumber(location.coordinate.latitude),
            "accuracy" : JSONValue.JNumber(location.horizontalAccuracy),
            "configAccuracy" : JSONValue.JString(accuracyConfig),
        ]
        
        var jsonDict = JSONValue.JObject(dict)
        SensorDataLogger.sharedInstance.logLineToFile(jsonDict.loggableString(), logType: .Location)
    }
    
    public class func logLocations(locations : [CLLocation], accuracyConfig: String) {
        for location : CLLocation in locations {
            logLocation(location, accuracyConfig: accuracyConfig)
        }
    }
    
}