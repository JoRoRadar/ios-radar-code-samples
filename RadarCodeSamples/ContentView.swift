//
//  ContentView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @EnvironmentObject var radarModel : RadarModel
    
    var body: some View {
        Map(coordinateRegion: $radarModel.region, interactionModes: [], showsUserLocation: true, annotationItems: radarModel.nearbyGeofences){ annotation in
            MapPin(coordinate: annotation.coordinate)
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static let radarModel : RadarModel = RadarModel()
    
    static var previews: some View {
        ContentView()
            .environmentObject(radarModel)
    }
}
