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
