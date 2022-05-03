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
    
    static var shared = AppManager()
}

/**
 Utility Extensions
 */

extension String {
    var firstLetterCapitilized: String {
        return prefix(1).capitalized + dropFirst()
    }
}
