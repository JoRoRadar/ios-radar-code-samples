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
    @StateObject var radarModel : RadarModel = RadarModel()
    
    private var RADAR_API_KEY:String?
    init(){
        RADAR_API_KEY = try! retrieveRadarAPIKey()
        
        Radar.initialize(publishableKey: RADAR_API_KEY!)
        Radar.setLogLevel(RadarLogLevel.none)
    }
    
    func retrieveRadarAPIKey() throws -> String {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            throw SetupError.apiKeyError("Could not load Radar API Key from pList")
        }
        
        guard let plist = NSDictionary(contentsOfFile: path) else{
            throw SetupError.apiKeyError("Could not read contents of pList")
        }
        
        if let radarAPIKey = plist["RadarAPIKey"]{
            return radarAPIKey as! String
        }else{
            throw SetupError.apiKeyError("'Info' pList does not contain a value for 'RadarAPIKey'.")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(radarModel)
                .onAppear(perform:{
                    radarModel.appDidLaunch()
                    if( String(RADAR_API_KEY!.prefix(8)) == "prj_test" ){
                        radarModel.radarAPIKeyType = Constants.Design.Primary.Text.rKeyTypeTextDev
                    }else{
                        radarModel.radarAPIKeyType = Constants.Design.Primary.Text.rKeyTypeTextProd
                    }
                })
        }
        .onChange(of: scenePhase) { phase in
            // Track phase change. Need to cache previous state to ignore inactive transitions. (Ex. Opening notification center)
            switch phase {
            case .active:
                AppManager.shared.appActive = true
            case .background:
                AppManager.shared.appActive = false
                if Radar.isTracking() && !radarModel.isOnTrip{
                    Radar.stopTracking()
                }
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
