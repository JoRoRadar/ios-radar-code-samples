//
//  RadarCodeSamplesApp.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import SwiftUI
import RadarSDK

@main
struct RadarCodeSamplesApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    let radarModel = RadarModel()
    
    init(){
        Radar.initialize(publishableKey: RADAR_API_KEY)
        
        Radar.setLogLevel(RadarLogLevel.debug)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { phase in
            // Track phase change. Need to cache previous state to ignore inactive transitions. (Ex. Opening notification center)
            switch phase {
            case .active:
                AppManager.shared.appActive = true
            case .background:
                AppManager.shared.appActive = false
            case .inactive:
                if !AppManager.shared.appActive {
                    radarModel.appDidEnterForeground()
                }
            default:
                break
            }
        }
    }
}
