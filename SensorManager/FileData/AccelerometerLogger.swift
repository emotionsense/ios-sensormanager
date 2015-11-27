//
//  AccelerometerLogger.swift
//  SensorManager
//
//  Created by Bruce Collie on 03/09/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

public class AccelerationLogger {
    
    public class func logAccelerometerData(data: [AccelerometerData], sampleLength: Int) {
        var formatter = NSDateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("HH:mm:ss:SSS dd MM yyyy Z z")
        formatter.locale = NSLocale(localeIdentifier: "US")
        
        if !data.isEmpty {
            
            let dict : [String : JSONValue] = [
                "sensorType" : JSONValue.JString("Accelerometer"),
                "xAxis" : JSONValue.JArray(data.map { (data : AccelerometerData) -> JSONValue in return JSONValue.JNumber(data.x) }),
                "yAxis" : JSONValue.JArray(data.map { (data : AccelerometerData) -> JSONValue in return JSONValue.JNumber(data.y) }),
                "zAxis" : JSONValue.JArray(data.map { (data : AccelerometerData) -> JSONValue in return JSONValue.JNumber(data.z) }),
                "sampleLengthMillis" : JSONValue.JNumber(sampleLength),
                "sensorTimeStamps" : JSONValue.JArray(data.map {
                    (data : AccelerometerData) -> JSONValue in
                        return JSONValue.JNumber(NSNumber(double: data.timestamp.timeIntervalSince1970 * 1000))
                    }),
                "senseStartTime" : JSONValue.JString(formatter.stringFromDate(data[0].timestamp)),
            ]
            
            let jsonDict = JSONValue.JObject(dict)
            SensorDataLogger.sharedInstance.logLineToFile(jsonDict.loggableString(), logType: .Accelerometer)
        }
    }
    
}