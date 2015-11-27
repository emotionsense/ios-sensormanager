//
//  SensorDataLogger.swift
//  SensorManager
//
//  Created by Bruce Collie on 28/08/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation
import SwiftyJSON

public class SensorDataLogger {
    
    private let directoryPath : String = ((NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true))[0] as! String).stringByAppendingPathComponent("logs")
    private let fileManager = NSFileManager.defaultManager()
    
    public var userIdentifier : String? = "USERID"

    public class var sharedInstance : SensorDataLogger {
    struct Shared {
        static let logger : SensorDataLogger = SensorDataLogger()
        }
        return Shared.logger
    }
    
    private init() {
    }
    
    internal let itemIsFile : (String -> Bool) = {
        (path : String) -> Bool in
        
        let filePath = SensorDataLogger.sharedInstance.directoryPath.stringByAppendingPathComponent(path)
        var isDirectory : ObjCBool = false
        if SensorDataLogger.sharedInstance.fileManager.fileExistsAtPath(filePath, isDirectory: &isDirectory) {
            return !isDirectory.boolValue
        }
        return false
    }
    
    ///This method should be used to log a single line of JSON data to the designated log file where it will be periodically uploaded.
    public func logLineToFile(line: String, logType: SensorType) {
        var error : NSError?
        let rawExistingContents = fileManager.contentsOfDirectoryAtPath(directoryPath, error: &error)
        var existingContents : [String] = []
        if error == nil {
            if let tryRaw = rawExistingContents {
                for rawItem : AnyObject in tryRaw {
                    existingContents.append(rawItem as! String)
                }
            }
        } else {
            println("We will have to create a new log file.")
        }
        
        var files : [String] = existingContents.filter(itemIsFile)
        
        var currentLogs : [String] = files.filter {
            (item : String) -> Bool in
            
            return item.uppercaseString.containsString(logType.rawValue.uppercaseString)
        }
        
        var logPath : String?
        if currentLogs.isEmpty {
            logPath = nil
        } else {
            if currentLogs.count > 1 {
                println("Warning: Should only have one log file per sensor at a time.")
            }
            logPath = currentLogs[0]
        }
        
        var logTime : Int64 = Int64(NSDate().timeIntervalSince1970 * 1000.0)
        
        var writePath : String
        if logPath == nil {
            var idComponent : String
            if let id = userIdentifier {
                idComponent = "\(id)-"
            } else {
                idComponent = ""
            }
            writePath = directoryPath.stringByAppendingPathComponent("\(idComponent)\(logType.rawValue.uppercaseString)-\(logTime)")
        } else {
            writePath = directoryPath.stringByAppendingPathComponent(logPath!)
        }
        
        writePath += ".log"
        
        println("Logging sensor data to: \(writePath). Time is: \(NSDate())")
        
        //Remove whitespace and newlines so that the data is written to the target file as a single physical line.
        let lineToWrite = "\(line.loggableString)\n"
        
        var fileHandle : NSFileHandle? = NSFileHandle(forWritingAtPath: writePath)
        if fileHandle == nil {
            fileManager.createDirectoryAtPath(writePath.stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: nil, error: nil)
            fileManager.createFileAtPath(writePath, contents: "".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true), attributes: nil)
            fileHandle = NSFileHandle(forWritingAtPath: writePath)
        }
        fileHandle!.seekToEndOfFile()
        fileHandle!.writeData(lineToWrite.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        fileHandle!.closeFile()
    }
    
}