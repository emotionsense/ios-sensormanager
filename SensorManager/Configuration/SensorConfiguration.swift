//
//  SensorConfiguration.swift
//  SensorManager
//
//  Created by Bruce Collie on 28/08/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

public typealias SensorAction = () -> ()
public typealias TimedSensorAction = (SensorAction, NSTimeInterval)

public struct SensorConfiguration {
    
    public static var momentaryActions : [SensorAction] = []
    public static var backgroundActions : [TimedSensorAction] = []
    public static var endBackgroundActions : [SensorAction] = []
    
    private static var timers : [NSTimer] = []
    
    private static var backgroundActive : Bool = false
    
    ///Currently only location momentary sensing is supported by the iOS app.
    public static func configureMomentarySensorsFromJSON(json: JSONValue) {
        
        println("Configuring momentary.")
        
        momentaryActions = []
        
        var sensorArray : [JSONValue] = json["sensors"].array ?? []
        for sensor : JSONValue in sensorArray {
            var optionalSensorType = SensorType(rawValue: sensor["sensor_type"].string ?? "NO_TYPE")
            if let sensorType = optionalSensorType {
                switch(sensorType) {
                case .Location:
                    var finalAccuracy : LocationAccuracy = LocationAccuracy.Fine
                    if let params = sensor["sensor_params"].object {
                        if let stringAccuracy : String = params["LOCATION_ACCURACY"]?.string {
                            if let accuracy = LocationAccuracy(rawValue: stringAccuracy) {
                                finalAccuracy = accuracy
                            }
                        }
                    }
                    momentaryActions.append(SensorActions.locationAction(finalAccuracy))
                default:
                    ()
                }
            }
        }
    }
    
    public static func configureBackgroundSensorsFromJSON(json: JSONValue) {
        backgroundActions = []
        
        var sensorArray : [JSONValue] = json["sensors"].array ?? []
        for sensor : JSONValue in sensorArray {
            var optionalSensorType = SensorType(rawValue: sensor["sensor_type"].string ?? "NO_TYPE")
            var sensePeriod : NSTimeInterval = Double(sensor["sense_if_last_data_older_than"].integer ?? 15) * 60.0 // Get the sensing period, defaulting to 15 minutes if none is found.
            
            if let sensorType = optionalSensorType {
                switch(sensorType) {
                case .Location:
                    //If a location action, then we just use a startBackgroundLoctionAction with an appropriate way to stop it.
                    backgroundActions.append(SensorActions.startBackgroundLocationAction())
                    endBackgroundActions.append(SensorActions.stopBackgroundLocationAction())
                case .Accelerometer:
                    let readTime : NSTimeInterval = (sensor["sensor_params"]["SENSE_WINDOW_LENGTH_MILLIS"].double.0 ?? 10000) / 1000.0 // Get the time to read data for, defaulting to 10 seconds
                    backgroundActions.append( (SensorActions.accelerometerAction(readTime), sensePeriod) )
                default:
                    ()
                }
            }
            
        }
    }
    
    ///This method is called when a survey is started in order to obtain sensor readings. It calls each SensorAction in the configured array.
    public static func sense() {
        momentaryActions.map { $0() }
    }
    
    ///This method is called when a user enters a study. It starts all background sensing for the study.
    public static func startBackgroundSensing() {
        
        if !backgroundActive {
            
            backgroundActive = true
            
            println("Invalidating previous timers before new ones are scheduled.")
            
            timers.map { $0.invalidate() }
            timers = []
            
            for (action, time) : TimedSensorAction in backgroundActions {
                action()
                if time != 0.0 {
                    println("Scheduling timers.")
                    var timer = NSTimer.scheduledTimerWithTimeInterval(time, block: action, repeats: true)
                    timers.append(timer)
                }
            }
            
        }
    }
    
    ///This method is called when a user leaves a study. It stops all background sensing for the study.
    public static func stopBackgroundSensing() {
        //Invalidate and remove all timers
        timers.map { $0.invalidate() }
        timers = []
        
        //Call any background cleanup actions.
        endBackgroundActions.map { $0() }
    }
    
}

///An enum type representing all supported sensor types on EasyM for iPhone.
public enum SensorType : String {
    
    case Location = "Location"
    case Accelerometer = "Accelerometer"
    
}