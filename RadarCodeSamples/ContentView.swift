//
//  ContentView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import SwiftUI

var RADAR_BLUE_COLOR = Color(red: 0.0, green: 0.4874, blue: 1.00)

struct ContentView: View {
    
    @EnvironmentObject var radarModel : RadarModel
    
    @State var isActive:Bool = false
    
    var body: some View {
        if self.isActive {
            FeatureView()
                .environmentObject(radarModel)
        }else{
            ZStack{
                Rectangle()
                    .fill(RADAR_BLUE_COLOR)
                    .edgesIgnoringSafeArea(.top)
                VStack{
                    Image("Radar_Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.leading, .trailing], 20)
                    Divider()
                        .padding([.leading, .trailing], 20)
                    Image("Radar_Sub_Title")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding([.leading, .trailing], 20)
                }
            }
            .onAppear(){
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isActive = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let radarModel : RadarModel = RadarModel()
    
    static var previews: some View {
        ContentView()
            .environmentObject(radarModel)
    }
}
