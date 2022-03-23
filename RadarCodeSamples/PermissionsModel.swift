//
//  PermissionsModel.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import Foundation
import RadarSDK

/**
 A simple model for requesting and managing location permission status.
 */
class PermissionsModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    @Published var permissionStatus: CLAuthorizationStatus = .notDetermined
    
    override init(){
        super.init()
        self.locationManager.delegate = self
        
        self.requestLocationPermissions()
    }
    
    /*
     If requesting background permissions, it is best to incrementally gain permissions otherwise the background permission prompt will trigger
     arbitrarily on a subsequent background location update. This disassociates the prompt from the app context leading to a lower opt-in rate.
     
     See the `locationManagerDidChangeAuthorization` delegate method for an alternative approach to requesting both permissions in a single session.
     
     Ex. If a user allows for foreground permissions on their first 'session', on their next session they will be prompted for background.
     */
    func requestLocationPermissions() {
        let status = self.locationManager.authorizationStatus
        
        if status == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
        }else if status == .denied {
            // It can be beneficial to notify a user on what features are disabled.
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.permissionStatus = manager.authorizationStatus
        
        /*
         If requesting background permissions in the same session, ensure that the permissionsStatus has already been authorized for when in use. Sequentially requesting
         always authorization will immediately prompt the user.
         
         Tying this status check and permission request to a user action will lead to higher opt-in rates.
         
         Permission Prompt Behavior: https://developer.apple.com/documentation/corelocation/cllocationmanager/1620551-requestalwaysauthorization
         */
//        if self.permissionStatus == .authorizedWhenInUse {
//            self.locationManager.requestAlwaysAuthorization()
//        }
    }
    
}
