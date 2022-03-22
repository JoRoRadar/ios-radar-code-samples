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
            if phase == .active {
                radarModel.appDidEnterForeground()
            }
        }
    }
}
