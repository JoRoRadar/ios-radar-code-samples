//
//  RadarModel.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import Foundation
import RadarSDK
import SwiftUI

class RadarModel: NSObject, RadarDelegate, ObservableObject {
    
    let permissionsModel = PermissionsModel()
    
    // Autocomplete Specific Properties
    
    @Published var autocompleteSuggestions: [String] = []
    var debounceTimer : Timer? // A timer is leveraged to ensure we are throttling API requests.
    
    //
    
    override init(){
        super.init()
        
        Radar.setUserId("SampleUser")
        Radar.setDescription("This is a Radar User created from the Radar Code Samples repo.")
        
        Radar.setMetadata(["CodeFeature" : ""])
    }
    
    // MARK: Autocomplete Functionality
    
    /**
        Generate autocomplete suggestions and present them to the user.
     
         Radar API's Used:
            1) Radar Autocomplete - Retrieve a list of address suggestions based on a text input.
     */
    public func generateAutocompleteSuggestions(textInput: String){
        
        // Invalidate the previous timer to ensure we are querying on the most recent text input.
        self.debounceTimer?.invalidate()
        
        // Perform query in 0.5 seconds
        self.debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false){ _ in
            
            // Submit text input to AutoComplete API
            Radar.autocomplete(query: textInput, near: nil, limit: 4) { (status:RadarStatus, addresses:[RadarAddress]?) in

                guard status == .success, let addresses = addresses else {
                    return
                }
                
                // Update UI to present results.
                self.autocompleteSuggestions = addresses.compactMap{ $0.formattedAddress }

            }
        }
    }
    
    /**
        As part of this sample, we assume the user is looking for geofences near a specific location. This function converts the address to a coordinate and performs the search.
     
         Radar API's Used:
            1) Radar Geocode - Convert address to coordinate pair.
            2) Radar Search Geofences - Search for geofences near coordinate pair.
     */
    public func searchForGeofencesNearAddress(textInput: String){
        
        // Geocode address input for address coordinates
        Radar.geocode(address: textInput) { (status: RadarStatus, addresses: [RadarAddress]? ) in
            guard status == .success, let addresses = addresses, !addresses.isEmpty else {
                return
            }
            
            // Convert address into CLLocation for subsequent geofence search.
            let addressCoordinate : CLLocation = CLLocation(latitude: addresses[0].coordinate.latitude, longitude: addresses[0].coordinate.longitude)
            
            // Search for geofences near the address the user submitted
            Radar.searchGeofences(near: addressCoordinate, radius: 500, tags: ["<RadarGeofenceTags>"], metadata: nil, limit: 10) { (status:RadarStatus, location: CLLocation?, geofences: [RadarGeofence]? ) in
                guard status == .success, let geofences = geofences else {
                    return
                }
                
                for geofence in geofences {
                    //Present Geofences
                }
            }
        }
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
    }
}
