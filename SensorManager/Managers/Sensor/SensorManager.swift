//
//  SensorManager.swift
//  SurveyManager
//
//  Created by Bruce Collie on 01/09/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON
import SensorManager

public class SensorManager : NSObject, NSCoding {
    
    internal var momentaryConfig : String
    internal var backgroundConfig : String
    
    public var userID : String
    
    private class var defaults : NSUserDefaults {
        struct Static {
            static var instance = NSUserDefaults.standardUserDefaults()
        }
        return Static.instance
    }
    
    private class var SensorKey : String {
        struct Static {
            static var instance = "easyMSensors"
        }
        return Static.instance
    }
    
    // MARK : Sensor Methods
    
    public class var sensorManager : SensorManager? {
        get {
            if let data : NSData = defaults.objectForKey(SensorKey) as? NSData {
                if let manager = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? SensorManager {
                    return manager
                }
            }
            return nil
        }
        set {
            if let tryNew = newValue {
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(tryNew), forKey: SensorKey)
            }
        }
    }
    
    public class func managerFromJSON(momentary: JSONValue, background: JSONValue, username: String) -> SensorManager? {
        return SensorManager(momentary: momentary.description, background: background.description, username: username)
    }
    
    private init(momentary: String, background: String, username: String) {
        momentaryConfig = momentary
        backgroundConfig = background
        userID = username
        super.init()
    }
    
    public required init(coder aDecoder: NSCoder) {
        momentaryConfig = aDecoder.decodeObjectForKey("momentaryConfig") as! String
        backgroundConfig = aDecoder.decodeObjectForKey("backgroundConfig")as! String
        userID = aDecoder.decodeObjectForKey("userID") as! String
        super.init()
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(momentaryConfig, forKey: "momentaryConfig")
        aCoder.encodeObject(backgroundConfig, forKey: "backgroundConfig")
        aCoder.encodeObject(userID, forKey: "userID")
    }
    
    public func configure() {
        if let m = decodeJSON(momentaryConfig) {
            SensorConfiguration.configureMomentarySensorsFromJSON(m)
        }
        if let b = decodeJSON(backgroundConfig) {
            SensorConfiguration.configureBackgroundSensorsFromJSON(b)
        }
        SensorDataLogger.sharedInstance.userIdentifier = userID
    }
    
    public func startBackgroundSensing() {
        println("Start sensing in background.")
        SensorConfiguration.startBackgroundSensing()
    }
    
    public func stopBackgroundSensing() {
        println("Stop sensing in background.")
        SensorConfiguration.stopBackgroundSensing()
    }
    
}