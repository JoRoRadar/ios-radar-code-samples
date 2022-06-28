//
//  Shopping_TrackingView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 5/16/22.
//

import SwiftUI
import MapKit
import RadarSDK

struct TrackingView: View {
    @EnvironmentObject private var radarModel : RadarModel
    
    @State var displayGeofences:[IdentifiableGeofence]
    
    @State var isShowingMap: Bool = false
    
    // TODO: Allow for trips to be started manually.
    @State var allowManualTrip:Bool = false
    
    init( selectedGeofence: IdentifiableGeofence){
        self.displayGeofences = [selectedGeofence]
    }
    
    var body: some View {
        VStack{
            Divider()
                .navigationBarTitle(Constants.Design.Tracking.Text.tNavigationTitle, displayMode: .inline)
                .onAppear{
                    radarModel.updateRegion()
                    if !allowManualTrip{
                        radarModel.startTripForSelectedLocation(selectedGeofence: displayGeofences[0])
                    }
                }
            if isShowingMap{
                MapTrackingView
            }else{
                StaticTrackingView
            }
            
            Divider()
            TrackingTitleGroup
            
            JourneyStatusView(selectedGeofence: $displayGeofences[0], expectedJourneyRemaining: $radarModel.tripTrackingStatus.expectedJourneyRemaining)
            Spacer()
            
            /// Present the user with the proper CTA buttons
            ///
            /// Scenario A (Automatic Trip Tracking): The application will start a Radar trip as a part of the checkout process automatically.
            ///
            /// Scenario B (Manual Trip Tracking): The application will prompt the user to indicate they are heading to the location to pickup their goods.
            ///
            /// All Scenarios: Once a user has received their items after arriving, an optional final touch point can prompt the user to indicate they have received
            /// their goods. Conversly, Radar provides the option to have a seperate party mark the trip as completed such as a store associate.
            ///
            /// TODO: Implement Manual Trip Tracking
            if radarModel.tripTrackingStatus.tripStatus == .arrived {
                CompleteTripViewButton(radarModel: radarModel)
            }else if allowManualTrip || radarModel.permissionsModel.permissionStatus != .authorizedAlways {
                StartTripViewButton(selectedGeofence: $displayGeofences[0], allowManualTrip: $allowManualTrip, radarModel: radarModel)
            }
        }
    }
    
    ///
    /// View Sections
    ///
    
    var MapTrackingView: some View{
        VStack{
            MapDisplayView(mapableGeofences: $displayGeofences, coordinateRegion: $radarModel.currentRegion)
            Button(action:{
                isShowingMap = false
            }){
                Label(Constants.Design.Tracking.Text.bSwapViewsText, systemImage:Constants.Design.Tracking.Image.bSwapViewsMapSysImg)
            }
        }
        .frame(width: Constants.screenWidth, height: Constants.screenHeight/4, alignment: .top)
    }
    
    var StaticTrackingView: some View{
        VStack{
            Image(systemName: Constants.Design.Tracking.Image.bSwapViewDefaultSysImage)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.primaryColor)
                .padding()
            Button(action:{
                isShowingMap = true
            }){
                Label(Constants.Design.Tracking.Text.bSwapViewsText, systemImage:Constants.Design.Tracking.Image.bSwapViewsDefaultSysImg)
            }
        }
        .frame(width: Constants.screenWidth/2, height: Constants.screenHeight/4)
    }
    
    var TrackingTitleGroup: some View{
        Group{
            Text(Constants.Design.Tracking.Text.jTitleText)
            TripJourneyView(journeyState: $radarModel.tripTrackingStatus.tripStatus)
                .padding()
            Divider()
        }
    }
}

// MARK: Radar Connected Views

struct StartTripViewButton: View {
    
    @Binding var selectedGeofence: IdentifiableGeofence
    @Binding var allowManualTrip: Bool
    
    var radarModel: RadarModel
    
    let dynamicButtonHeight : CGFloat = 50
    let dyanmicButtonFontSize : CGFloat = 14
    
    var body: some View{
        Text(Constants.Design.Tracking.Text.jManualText)
            .fontWeight(.ultraLight)
            .font(.system(size:dyanmicButtonFontSize))
            .multilineTextAlignment(.center)
        Button(action:{
            radarModel.startTripForSelectedLocation(selectedGeofence: selectedGeofence)
            allowManualTrip = false
        }){
            Label(Constants.Design.Tracking.Text.bManual, systemImage: Constants.Design.Tracking.Image.bManualTripSysImg)
                .frame(width: Constants.screenWidth, height: dynamicButtonHeight, alignment: .center)
        }
        .buttonStyle(PrimaryColorButtonStyle())
    }
}

struct CompleteTripViewButton: View {
    
    var radarModel: RadarModel
    
    let dynamicButtonHeight : CGFloat = 50
    let dyanmicButtonFontSize : CGFloat = 14
    
    var body: some View{
        Text(Constants.Design.Tracking.Text.jArrivedText)
            .fontWeight(.ultraLight)
            .font(.system(size:dyanmicButtonFontSize))
            .multilineTextAlignment(.center)
        Button(action:{
            radarModel.completeCurrentTrip()
        }){
            Label(Constants.Design.Tracking.Text.bTripComplete, systemImage: Constants.Design.Tracking.Image.bTripCompleteSysImage)
                .frame(width: Constants.screenWidth, height: dynamicButtonHeight, alignment: .center)
        }
            .buttonStyle(PrimaryColorButtonStyle())
    }
}
