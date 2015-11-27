//
//  AccelerometerManager.swift
//  SensorManager
//
//  Created by Bruce Collie on 26/08/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import CoreMotion

public class AccelerometerManager {
    
    public var unitType : AccelerometerUnitType = .MetersPerSecondSquared
    
    ///An array holding all the accelerometer readings from the current run.
    public var readings : [AccelerometerData] = []
    
    ///Optional date object representing the start time of the current set of readings. Nil when no data has been recorded yet.
    public var sensingStartTime : NSDate?
    ///Optional date object representing the end time of the current set of readings. Nil when reading is in progress or has not started yet.
    public var sensingEndTime : NSDate?
    
    ///The time between accelerometer readings, measured in seconds.
    public var updateInterval : NSTimeInterval {
        get {
            //Drops back to getting / setting properties on the shared CMMotionManager so that only one instance exists at any one time.
            return BaseMotionManager.sharedInstance.manager.accelerometerUpdateInterval
        }
        set {
            BaseMotionManager.sharedInstance.manager.accelerometerUpdateInterval = newValue
        }
    }
    
    ///An optional callback that is called with new accelerometer data every time some is ready.
    public var onNewData : (AccelerometerData -> Void)?
    
    ///An optional callback that is called when we have finished reading a timed set of data.
    public var onReadFinished : ([AccelerometerData] -> Void)?
    
    public class var sharedInstance : AccelerometerManager {
        struct Static {
            static let instance : AccelerometerManager = AccelerometerManager()
        }
        return Static.instance
    }
    
    //Private initialiser to prevent users from creating another instance.
    private init() {
        updateInterval = 1.0
    }
    
    ///Begin recording accelerometer data.
    internal func startReading() {
        
        //Need to remove previous readings before recording starts.
        readings = []
        
        sensingStartTime = NSDate()
        sensingEndTime = nil
        
        BaseMotionManager.sharedInstance.manager.startAccelerometerUpdatesToQueue(NSOperationQueue(), withHandler: {
            (data : CMAccelerometerData!, error : NSError!) -> Void in
            
            //The iPhone accelerometer gives values in multiples of G by default, but EasyM wants values in ms^-2, so we allow for a conversion factor.
            var multiplier : Double = 1.0
            switch self.unitType {
                case .MetersPerSecondSquared:
                    multiplier = 9.80665
                case .MultiplesOfG:
                    multiplier = 1.0
            }
            
            let newData : AccelerometerData = AccelerometerData(
                x: data.acceleration.x * multiplier,
                y: data.acceleration.y * multiplier,
                z: data.acceleration.z * multiplier,
                timestamp: NSDate()
            )
            
            self.readings.append(newData)
            
            if let callback = self.onNewData {
                callback(newData)
            }
            
        })
    }
    
    ///Stops recording the accelerometer data and leaves the recorded data for processing.
    internal func stopReading() {
        BaseMotionManager.sharedInstance.manager.stopAccelerometerUpdates()
        sensingEndTime = NSDate()
    }
    
    public func readForTime(time: NSTimeInterval) {
        startReading()
        
        Async.background {
            NSThread.sleepForTimeInterval(time)
            self.stopReading()
            
            if let callback = self.onReadFinished {
                callback(self.readings)
            }
        }
    }
    
}

///Value type representing a single reading from the accelerometer, including x, y, and z acceleration along with a timestamp.
public struct AccelerometerData {
    
    public let x : Double
    public let y : Double
    public let z : Double
    
    public let timestamp : NSDate
    
}

///Encodes the unit type returned by the accelerometer manager.
public enum AccelerometerUnitType {
    
    case MetersPerSecondSquared
    case MultiplesOfG
    
}