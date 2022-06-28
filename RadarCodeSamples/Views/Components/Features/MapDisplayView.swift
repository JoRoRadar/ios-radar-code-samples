//
//  MapDisplayView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 6/27/22.
//

import SwiftUI
import MapKit

struct MapDisplayView: View {
    @Binding var mapableGeofences: [IdentifiableGeofence]
    @Binding var coordinateRegion: MKCoordinateRegion
    
    var body: some View{
            Map(
                coordinateRegion: $coordinateRegion,
                showsUserLocation: true,
                annotationItems: mapableGeofences){ geofence in
                    MapAnnotation(coordinate: geofence.location){
                        CustomMapAnnotation(isDummyMarker: geofence.isDummy, displayText: geofence.description)
                    }
            }
    }
}

struct CustomMapAnnotation: View {
    
    @State private var showDisplayText: Bool = true
    
    let isDummyMarker: Bool
    let displayText: String
    
    var body: some View{
        VStack(spacing:0){
            if( !self.isDummyMarker){
                Text(displayText)
                    .font(.title)
                    .padding(5)
                    .background(Color(.white))
                    .cornerRadius(10)
                    .opacity(showDisplayText ? 0 : 1)
            }
            
            Image(systemName: self.isDummyMarker ? Constants.Design.NearbyLocator.Image.mapDisplayDummyPinImg : Constants.Design.NearbyLocator.Image.mapDisplayGeofencePinImg_0)
              .font(.title)
              .foregroundColor(self.isDummyMarker ? .red : .primaryColor)
            
            if( !self.isDummyMarker){
                Image(systemName: Constants.Design.NearbyLocator.Image.mapDisplayGeofencePinImg_1)
                  .font(.caption)
                  .foregroundColor(.primaryColor)
                  .offset(x: 0, y: -5)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut){
                showDisplayText.toggle()
            }
        }
    }
}
