//
//  error.swift
//  nifty
//
//  Created by Mitchell Allison on 05/11/2014.
//  Copyright (c) 2014 mitchellallison. All rights reserved.
//

import Foundation

public func ==(lhs: SCError, rhs: SCError) -> Bool {
    return lhs.message == rhs.message && lhs.lineContext == rhs.lineContext
}

public class SCError: NSObject, Printable, Equatable {
    var message: String
    var lineContext: LineContext
    
    override public var description: String {
        return "Error encountered at line: " + lineContext.line.description + ", pos: " + lineContext.pos.description + ": " + message
    }
    
    init(message: String, lineContext: LineContext) {
        self.message = message
        self.lineContext = lineContext
    }
}
