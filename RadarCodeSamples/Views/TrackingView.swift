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
    
    @Binding var selectedGeofence:IdentifiableGeofence
    
    @State var isShowingMap: Bool = false
    @State var allowManualTrip:Bool = false
    
    var body: some View {
        VStack{
            Divider()
                .navigationBarTitle(Constants.Design.Tracking.Text.tNavigationTitle, displayMode: .inline)
                .onAppear{
                    if !allowManualTrip{
                        radarModel.startTripForSelectedLocation(selectedGeofence: selectedGeofence)
                    }
                }
            MapDisplayView(isShowingMap: $isShowingMap, selectedGeofence: $selectedGeofence, coordinateRegion: $radarModel.currentRegion)
            
            Divider()
            Group{
                Text(Constants.Design.Tracking.Text.jTitleText)
                Journey(journeyState: $radarModel.tripStatus)
                    .padding()
                Divider()
            }
            
            JourneyStatusView(selectedGeofence: $selectedGeofence, expectedJourneyRemaining: $radarModel.expectedJourneyRemaining)
            Spacer()
            
            if radarModel.tripStatus == .arrived {
                CompleteTripViewButton(radarModel: radarModel)
            }else if allowManualTrip || radarModel.permissionsModel.permissionStatus != .authorizedAlways {
                StartTripViewButton(selectedGeofence: $selectedGeofence, allowManualTrip: $allowManualTrip, radarModel: radarModel)
            }
        }
    }
}

// MARK: Supporting Views

struct Line:Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y:0))
        path.addLine(to: CGPoint(x: rect.width, y:0))
        return path
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

struct JourneyStatusView: View {
    
    @Binding var selectedGeofence: IdentifiableGeofence
    
    @Binding var expectedJourneyRemaining: Int?
    
    var body: some View{
        HStack{
            Text(Constants.Design.Tracking.Text.jNearestStoreText)
            Text(selectedGeofence.description)
                .fontWeight(.heavy)
        }
        HStack{
            Text(Constants.Design.Tracking.Text.jExpectedArrivalText)
            if expectedJourneyRemaining != nil{
                Text("\(expectedJourneyRemaining!) minute(s)")
                    .fontWeight(.heavy)
            }else{
                Text(Constants.Design.Tracking.Text.jExpectedArrivalFallbackText)
                    .fontWeight(.heavy)
            }
        }
    }
}

struct MapDisplayView: View {
    
    @Binding var isShowingMap: Bool
    @Binding var selectedGeofence: IdentifiableGeofence
    
    @Binding var coordinateRegion: MKCoordinateRegion
    
    var body: some View{
        
        if isShowingMap{
            VStack{
                Map(
                    coordinateRegion: $coordinateRegion,
                    showsUserLocation: true,
                    annotationItems: [selectedGeofence]){ geofence in
                        MapMarker(coordinate: geofence.location, tint: Color.primaryColor)
                }
                Button(action:{
                    isShowingMap = false
                }){
                    Label(Constants.Design.Tracking.Text.bSwapViewsText, systemImage:Constants.Design.Tracking.Image.bSwapViewsMapSysImg)
                }
            }
            .frame(width: Constants.screenWidth, height: Constants.screenHeight/4, alignment: .top)
        }else{
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
        
    }
}

struct Journey:View {
    
    @Binding var journeyState:RadarTripStatus
    
    let connectorLineWidth:CGFloat = 1
    let connectorLineDash:CGFloat = 2
    let connectorLineFrameWidth:CGFloat = 15
    let connectLineFrameHeight:CGFloat = 2
    
    var body: some View{
        HStack{
            
            JourneryStateCell(journeyState: $journeyState, stateName: Constants.Design.Tracking.Text.jStartedState, cellState: .started)
            if( journeyState == .started ){
                Line().stroke(style: StrokeStyle(lineWidth:connectorLineWidth, dash:[connectorLineDash])).frame(width:connectorLineFrameWidth, height:connectLineFrameHeight).foregroundColor(Color.secondaryColor)
            }else{
                Rectangle().fill(.black).frame(width: connectorLineFrameWidth, height: connectLineFrameHeight, alignment: .center)
            }
            
            JourneryStateCell(journeyState: $journeyState, stateName: Constants.Design.Tracking.Text.jApproachingState, cellState: .approaching)
            if( journeyState == .approaching ){
                Line().stroke(style: StrokeStyle(lineWidth:connectorLineWidth, dash:[connectorLineDash])).frame(width:connectorLineFrameWidth, height:connectLineFrameHeight).foregroundColor(Color.secondaryColor)
            }else{
                Rectangle().fill(.black).frame(width: connectorLineFrameWidth, height: connectLineFrameHeight, alignment: .center)
            }
            
            JourneryStateCell(journeyState: $journeyState, stateName: Constants.Design.Tracking.Text.jArrivedState, cellState: .arrived)
            if( journeyState == .arrived ){
                Line().stroke(style: StrokeStyle(lineWidth:connectorLineWidth, dash:[connectorLineDash])).frame(width:connectorLineFrameWidth, height:connectLineFrameHeight).foregroundColor(Color.secondaryColor)
            }else{
                Rectangle().fill(.black).frame(width: connectorLineFrameWidth, height: connectLineFrameHeight, alignment: .center)
            }
            
            JourneryStateCell(journeyState: $journeyState, stateName: Constants.Design.Tracking.Text.jCompletedState, cellState: .completed)
        }
    }
}

struct JourneryStateCell:View {
    
    @Binding var journeyState: RadarTripStatus
    
    var stateName: String
    var cellState: RadarTripStatus
    
    let fontSize:CGFloat = 10
    
    var body: some View {
        VStack{
            if journeyState == cellState{
                Image(systemName: Constants.Design.Tracking.Image.jStateCurrentFilledSysImg)
                    .foregroundColor(Color.secondaryColor)
            }else{
                Image(systemName: journeyState.rawValue > cellState.rawValue ? Constants.Design.Tracking.Image.jStateFilledSysImg : Constants.Design.Tracking.Image.jStateNotFilledSysImg)
                    .foregroundColor(Color.primaryColor)
            }
            Text(stateName)
                .font(.system(size:fontSize))
        }
    }
}
