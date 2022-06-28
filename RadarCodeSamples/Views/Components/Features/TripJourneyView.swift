//
//  TripJourneyView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 6/27/22.
//

import SwiftUI
import RadarSDK

struct TripJourneyView: View {
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
