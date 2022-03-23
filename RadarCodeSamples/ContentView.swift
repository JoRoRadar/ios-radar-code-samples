//
//  ContentView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var radarModel : RadarModel
    
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static let radarModel : RadarModel = RadarModel()
    
    static var previews: some View {
        ContentView()
            .environmentObject(radarModel)
    }
}
