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
        Radar.initialize(publishableKey: "prj_test_pk_a5515e9736bf2c38504505a92f7d0c3ac6c1c8b8")
        
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
