//
//  Extensions.swift
//  SensorManager
//
//  Created by Bruce Collie on 01/09/2014.
//  Copyright (c) 2014 University of Cambridge Computer Laboratory. All rights reserved.
//

import Foundation

extension String {

    public var uppercaseString : String {
        return (self as NSString).uppercaseString
    }

    public var lowercaseString : String {
        return (self as NSString).lowercaseString
    }

    public func containsString(string: String) -> Bool {
        return (self as NSString).containsString(string)
    }

    public var loggableString : String {
        return self.stringByReplacingOccurrencesOfString("\n", withString: "", options: .RegularExpressionSearch, range: nil)
    }

}