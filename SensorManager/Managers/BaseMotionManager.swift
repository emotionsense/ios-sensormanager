//
//  BaseSensorManager.swift
//  SensorManager
//
//  Created by Bruce Collie on 26/08/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import CoreMotion

///This is an internal class designed to encapsulate a single instance of CMMotionManager in order that only one is ever created.
class BaseMotionManager {
    
    var manager : CMMotionManager = CMMotionManager()
    
    internal class var sharedInstance : BaseMotionManager {
        struct Static {
            static let shared : BaseMotionManager = BaseMotionManager()
        }
        return Static.shared
    }
    
    private init() {
    }
    
}