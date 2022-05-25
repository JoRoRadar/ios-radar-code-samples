//
//  AppManager.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import Foundation

/**
 Manages the App State; particularly for identifying background <> foreground transitions. 
 */
class AppManager {
    var appActive = false
    var appType : AppType = .None
    
    static var shared = AppManager()
}

/**
 Utility Extensions/Functions/Enums
 */

enum SetupError: Error{
    case apiKeyError(String)
}

enum AppType : CustomStringConvertible {
    case None
    case QSR
    case Settings
    
    var description : String {
        switch self {
        case .None: return "None"
        case .QSR: return "QSR"
        case .Settings: return "Settings"
        }
    }
}

extension String {
    var firstLetterCapitilized: String {
        return prefix(1).capitalized + dropFirst()
    }
}
