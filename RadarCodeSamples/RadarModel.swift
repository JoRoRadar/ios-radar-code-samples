//
//  RadarModel.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import Foundation
import RadarSDK

class RadarModel: NSObject, RadarDelegate {
    
    let permissionsModel = PermissionsModel()
    
    override init(){
        super.init()
        
        Radar.setUserId("SampleUser")
        Radar.setDescription("This is a Radar User created from the Radar Code Samples repo.")
        
        Radar.setMetadata(["CodeFeature" : ""])
        
    }
    
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
    }
}
