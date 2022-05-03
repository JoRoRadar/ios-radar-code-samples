//
//  FeatureView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 5/2/22.
//

import SwiftUI

/*
 Features
 Autocomplete
 StoreLocator
 Trip Tracking
 InStore Mode
 */
struct FeatureView: View {
    
    @EnvironmentObject var radarModel : RadarModel
    
    var body: some View {
        VStack{
            Image("Radar_Logo")
                .resizable()
                .renderingMode(Image.TemplateRenderingMode.template)
                .foregroundColor(RADAR_BLUE_COLOR)
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width/2)
                .padding(.top, 10)
            Divider()
            Spacer()
            VStack{
                FeatureSet(imageA: "shopping_app", imageAText: "Shopping", imageB: "qsr_app", imageBText: "Food")
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.5, alignment: .center)
            Spacer()
            Divider()
            ScrollView{
                VStack( alignment: .trailing){
                    
                    let apiTextColor: Color = radarModel.radarAPIKeyType == "Production" ? Color.blue : Color.green
                    RadarStatusRow(rowTitle: "Radar API Key Type", rowBody: "Production", bodyColor: apiTextColor)
                    
                    let authTextColor: Color = radarModel.permissionsModel.permissionStatus.isRestrictedPermission ? Color.red : Color.black
                    RadarStatusRow(rowTitle: "Authorization Status", rowBody: radarModel.permissionsModel.permissionStatus.description, bodyColor: authTextColor)
                    
                    RadarStatusRow(rowTitle: "Radar Tracking Mode", rowBody: radarModel.trackingMode)
                    RadarStatusRow(rowTitle: "Radar User Name", rowBody: radarModel.radarUserId)
                    RadarStatusRow(rowTitle: "Radar Trip Status", rowBody: radarModel.isOnTrip.description.firstLetterCapitilized
                    )
                    RadarStatusRow(rowTitle: "Current Geofence", rowBody: radarModel.currentGeofence)
                }
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.25, alignment: .bottom)
        }
        .ignoresSafeArea()
    }
}

struct FeatureSet: View{
    
    var imageA: String
    var imageAText: String
    
    var imageB: String
    var imageBText: String
    
    var body: some View{
        HStack{
            Spacer()
            FeatureButton(featureText: imageAText , imageName: imageA)
            Spacer()
            FeatureButton(featureText: imageBText, imageName: imageB)
            Spacer()
        }
    }
}

struct FeatureButton: View{
    
    var featureText: String
    var imageName: String
    
    var borderSize: Double = 2
    var imagePadding: Double = 1
    var textPadding: Double = 5
    
    let defaultShadowColor: Color = Color(red: 0.151, green: 0.157, blue: 0.166, opacity: 0.100)
    let activeShadowColor: Color = RADAR_BLUE_COLOR
    
    @State var buttonShadowColor: Color = Color(red: 0.151, green: 0.157, blue: 0.166, opacity: 0.100)
    
    var body: some View{
        
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .fill(buttonShadowColor)
                .overlay(alignment: .center){
                    RoundedRectangle(cornerRadius: 15)
                        .strokeBorder(RADAR_BLUE_COLOR)
                        .background(RoundedRectangle(cornerRadius: 15).fill(Color.white))
                        .offset(x: -2, y: -2)
                }

            VStack(alignment: .center){
                Image(imageName)
                    .resizable()
                    .renderingMode(Image.TemplateRenderingMode.template)
                    .foregroundColor(RADAR_BLUE_COLOR)
                    .aspectRatio(contentMode: .fit)
                    .padding([.all], borderSize + imagePadding)

                Spacer()
                Text(featureText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.25)
                    .padding([.leading, .trailing, .bottom], textPadding)
            }
            .padding(borderSize)
            
        }
        .frame(width: UIScreen.main.bounds.width/3, height:UIScreen.main.bounds.width/3, alignment: .leading)
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged({ _ in
                buttonShadowColor = activeShadowColor
            })
            .onEnded({ _ in
                buttonShadowColor = defaultShadowColor
            })
        )
    }
}

struct RadarStatusRow: View{
    var rowTitle:String
    var rowBody: String
    var bodyColor: Color = Color.black
    
    var body: some View{
        HStack{
            Text(rowTitle)
                .frame(width:UIScreen.main.bounds.width/2, alignment: .leading)
                .lineLimit(1)
            Divider()
            ScrollView(.horizontal, showsIndicators: false){
                Text(rowBody)
                    .lineLimit(1)
                    .foregroundColor(bodyColor)
            }
            .frame(width:UIScreen.main.bounds.width/3)
        }
    }
}

struct FeatureView_Previews: PreviewProvider {
    static var previews: some View {
        FeatureView()
    }
}
