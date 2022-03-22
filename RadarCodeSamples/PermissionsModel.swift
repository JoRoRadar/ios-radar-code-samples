//
//  PermissionsModel.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import Foundation
import RadarSDK

class PermissionsModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    
    @Published var permissionStatus: CLAuthorizationStatus = .notDetermined
    
    override init(){
        super.init()
        self.locationManager.delegate = self
        
        self.requestLocationPermissions()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.permissionStatus = manager.authorizationStatus
    }
    
    func requestLocationPermissions() {
        let status = self.locationManager.authorizationStatus
        
        if status == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
        }else if status == .notDetermined {
            // Notify user of disabled features.
        }
    }
    
}
