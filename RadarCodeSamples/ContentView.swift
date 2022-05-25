//
//  ContentView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var radarModel : RadarModel
    
    @State var isActive:Bool = false
    
    var body: some View {
        if self.isActive {
            FeatureView()
                .statusBar(hidden: true)
                .environmentObject(radarModel)
        }else{
            SplashScreen()
                .statusBar(hidden: true)
                .onAppear(){
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isActive = true
                    }
                }
        }
    }
}

struct SplashScreen : View {
    var body: some View{
        ZStack{
            Rectangle()
                .fill(Color.primaryColor)
                .edgesIgnoringSafeArea([.top, .bottom])
            VStack{
                Image(Constants.Design.Primary.Image.radarLogoImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding([.leading, .trailing], 20)
                Divider()
                    .padding([.leading, .trailing], 20)
                Image(Constants.Design.Primary.Image.radarSubtitleImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding([.leading, .trailing], 20)
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
