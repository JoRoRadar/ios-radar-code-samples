//
//  GeofencePicker.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 6/27/22.
//

import SwiftUI

struct GeofencePicker: View {
    @Binding var selectedGeofence : IdentifiableGeofence?
    
    @State var defaultLocationText:String = Constants.Design.QSR.Text.qPickupLocationDefaultText
    @State private var showPicker: Bool = false
    
    var radarModel: RadarModel
    
    let frameHeight: CGFloat = 50
    let asyncWaitPeriod: CGFloat = 4
    let maxRetryAttempts: Int = 3
    
    var body: some View{
        if( showPicker && selectedGeofence != nil){
            HStack{
                Text(Constants.Design.QSR.Text.qPickupLocationTitle)
                Divider()
                Picker(Constants.Design.QSR.Text.qPickerTitle, selection:Binding($selectedGeofence)!){
                    ForEach(radarModel.nearbyGeofences, id: \.self){ geofence in
                        // The Dummy flag indicates that a pin needs to be added to the map but it is not a valid Radar geofence to present the user as a store option. This flag is not present on the base RadarGeofence class.
                        if !geofence.isDummy {
                            Text(geofence.description).tag(geofence)
                        }
                    }
                }
            }
            .frame(width: Constants.screenWidth, height: frameHeight)
        }else{
            Text(defaultLocationText)
                .frame(width: Constants.screenWidth, height: frameHeight)
                .onAppear(){
                    self.updatePickerValues()
                }
        }
    }
    
    // MARK: Helper ASYNC Functions
    
    func updatePickerValues(retryAttempts: Int = 0){
        if retryAttempts > self.maxRetryAttempts{
            return
        }
        
        //Allow for Radar callbacks to complete
        self.radarModel.findNearbyLocations()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + asyncWaitPeriod) {
            if self.radarModel.nearbyGeofences.count == 0{
                defaultLocationText = Constants.Design.QSR.Text.qPickupLocationFallbackText
                self.updatePickerValues(retryAttempts: retryAttempts + 1)
            }else{
                selectedGeofence = radarModel.nearbyGeofences[0]
                showPicker = true
            }
        }
    }
}
