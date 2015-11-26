//
//  ColorLog.swift
//  whats-new
//
//  Created by Sam Dean on 03/11/2015.
//  Copyright © 2015 net-a-porter. All rights reserved.
//

import Foundation

/**
 Helped out from here : `https://github.com/robbiehanson/XcodeColors`
 
 Designed to work with the XcodeColors Xcode plugin (I use Alcatraz to install it)
 
 Call `ColorLog.enabled = true` early on if you want it :)
*/
public struct ColorLog {
    /**
     Set this to true to add colour output. Defaults to `false`.
     */
    public static var enabled = false
    
    private static let ESCAPE = "\u{001b}["
    
    private static let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
    private static let RESET_BG = ESCAPE + "bg;" // Clear any background color
    private static let RESET = ESCAPE + ";"   // Clear any foreground or background color
    
    static func red<T>(object: T) -> String {
        return enabled ? "\(ESCAPE)fg200,0,0;\(object)\(RESET)" : "\(object)"
    }
    
    static func green<T>(object: T) -> String {
        return enabled ? "\(ESCAPE)fg0,127,0;\(object)\(RESET)" : "\(object)"
    }
    
    static func darkGreen<T>(object: T) -> String {
        return enabled ? "\(ESCAPE)fg0,96,0;\(object)\(RESET)" : "\(object)"
    }
    
    static func lightGreen<T>(object: T) -> String {
        return enabled ? "\(ESCAPE)fg64,127,64;\(object)\(RESET)" : "\(object)"
    }
    
    static func gray<T>(object: T) -> String {
        return enabled ? "\(ESCAPE)fg127,127,127;\(object)\(RESET)" : "\(object)"
    }
}
