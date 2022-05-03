//
//  RadarModel.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import Foundation
import RadarSDK

class RadarModel: NSObject, RadarDelegate, ObservableObject {
    
    var radarUserId: String = "SampleUser"
    
    var radarAPIKeyType: String = "Production"
    
    @Published var trackingMode: String = "Foreground Only"
    @Published var isOnTrip: Bool = false
    @Published var currentGeofence: String = "None"
    
    var permissionsModel = PermissionsModel()
    
    override init(){
        super.init()
        
        Radar.setUserId(radarUserId)
        Radar.setDescription("This is a Radar User created from the Radar Code Samples repo.")
        
        Radar.setMetadata(["CodeFeature" : ""])
    }
    
    // MARK: Radar Tracking Updates
    
    /*
     Wrapper function for updating UI values.
     */
    func startTracking(mode: RadarTrackingOptions? ) {
        
        switch mode {
            case RadarTrackingOptions.presetResponsive:
                self.trackingMode = "Responsive (BG)"
            case RadarTrackingOptions.presetEfficient:
                self.trackingMode = "Efficient (BG)"
            case RadarTrackingOptions.presetContinuous:
                self.trackingMode = "Continuous (BG)"
            default:
                Radar.stopTracking()
                self.trackingMode = "Foreground Only"
                return
        }
        
        Radar.startTracking(trackingOptions: mode!)
    }
    
    // MARK: App State Changes
    
    public func appDidEnterForeground(){
        print("App Entered Foreground")
    }
    
    // MARK: Primary Radar Events
    
    func didReceiveEvents(_ events: [RadarEvent], user: RadarUser?) {
        
    }
    
    // MARK: Additional Radar Events
    
    func didUpdateClientLocation(_ location: CLLocation, stopped: Bool, source: RadarLocationSource) {
    }
    
    func didFail(status: RadarStatus) {
    }
    
    func didLog(message: String) {
    }
    
    func didUpdateLocation(_ location: CLLocation, user: RadarUser) {
        guard let geofence = user.geofences else{
            return
        }
        
        if geofence.count > 0 {
            self.currentGeofence = geofence[0].__description
        }
    }
}
