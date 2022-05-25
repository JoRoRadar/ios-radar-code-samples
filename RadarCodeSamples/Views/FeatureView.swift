//
//  FeatureView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 5/2/22.
//

import SwiftUI

struct FeatureView: View {
    
    @EnvironmentObject var radarModel : RadarModel
    
    @State var activeAppType:AppType? = .None
    
    let rLogoImagePadding : CGFloat = 10
    
    var body: some View {
        NavigationView{
            VStack{
                //Setup nav bar, navigation links, and header
                NavigationViews(radarModel: radarModel, activeAppType: $activeAppType)
                    .navigationBarHidden(true)
                
                Image(Constants.Design.Primary.Image.radarLogoImage)
                    .resizable()
                    .renderingMode(Image.TemplateRenderingMode.template)
                    .foregroundColor(Color.primaryColor)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.screenWidth/2)
                    .padding(.top, rLogoImagePadding)
                Divider()
                Spacer()
                
                //Setup and link available sample apps to launch
                VStack{
                    Text(Constants.Design.Feature.Text.fTitle)
                        .fontWeight(.semibold)
                    HStack{
                        Spacer()
                        FeatureButton(appStateBinding: $activeAppType, buttonState: .QSR, featureText: Constants.Design.Feature.Text.fQSRButtonText, imageName: Constants.Design.Feature.Image.fQSRAppImage)
                        Spacer()
                    }
                }
                Spacer()
                Divider()
                
                //Setup Radar connection status table.
                RadarStatusTable(activeAppType: $activeAppType, radarModel: radarModel)
                    .frame(width: Constants.screenWidth, height: Constants.screenHeight/3, alignment: .bottom)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    struct NavigationViews : View {
        
        var radarModel: RadarModel
        
        @Binding var activeAppType: AppType?
        
        var body: some View{
            NavigationLink(
                destination: MenuView().environmentObject(radarModel),
                tag: AppType.QSR,
                selection: $activeAppType) { EmptyView() }
            NavigationLink(
                destination: TrackingSettingsView().environmentObject(radarModel),
                tag: AppType.Settings,
                selection: $activeAppType) { EmptyView() }
        }
    }
}

// MARK: Supporting Views

struct FeatureButton: View{
    
    @Binding var appStateBinding: AppType?
    
    @State var buttonCurrentShadowColor : Color = Color.primaryShadowColor
    
    var buttonState: AppType
    
    var featureText: String
    var imageName: String
    
    let borderSize: Double = 2
    let imagePadding: Double = 1
    let textPadding: Double = 5
    let cornerRadius : Double = 15
    let textScaleMultiplier : Double = 0.25
    
    var body: some View{
        
        ZStack{
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(buttonCurrentShadowColor)
                .overlay(alignment: .center){
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.primaryColor)
                        .background(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white))
                        .offset(x: -2, y: -2)
                }

            VStack(alignment: .center){
                Image(imageName)
                    .resizable()
                    .renderingMode(Image.TemplateRenderingMode.template)
                    .foregroundColor(Color.primaryColor)
                    .aspectRatio(contentMode: .fit)
                    .padding([.all], borderSize + imagePadding)
                Text(featureText)
                    .lineLimit(1)
                    .minimumScaleFactor(textScaleMultiplier)
                    .padding([.leading, .trailing, .bottom], textPadding)
            }
            .padding(borderSize)
            
        }
        .frame(width: Constants.screenWidth/3, height:Constants.screenWidth/3, alignment: .leading)
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged({ _ in
                buttonCurrentShadowColor = Color.primaryColor
            })
            .onEnded({ _ in
                buttonCurrentShadowColor = Color.primaryShadowColor
                appStateBinding = buttonState
            })
        )
    }
}

struct RadarStatusRow: View{
    
    var rowTitle:String
    var rowBody: String
    
    var textColor: Color
    
    var body: some View{
        HStack{
            Text(rowTitle)
                .frame(width:Constants.screenWidth/2, alignment: .leading)
                .lineLimit(1)
            Divider()
            ScrollView(.horizontal, showsIndicators: false){
                Text(rowBody)
                    .lineLimit(1)
                    .foregroundColor(textColor)
            }
        }
    }
}

// MARK: Radar Connected Views

struct RadarStatusTable: View {
    
    @Binding var activeAppType : AppType?
    
    var radarModel: RadarModel
    
    let bCustomizePadding : CGFloat = 25
    let bCustomizeRadius : CGFloat = 50
    
    var body: some View{
        ScrollView{
            VStack( alignment: .leading){
                Group{
                    //Retrieve Radar settings
                    let isProdKey = radarModel.radarAPIKeyType == Constants.Design.Primary.Text.rKeyTypeTextProd
                    let apiTextColor: Color = isProdKey ? Color.primaryColor : Color.secondaryColor
                    let keyStatusText = isProdKey ? Constants.Design.Primary.Text.rKeyTypeTextProd : Constants.Design.Primary.Text.rKeyTypeTextDev
                    RadarStatusRow(rowTitle: Constants.Design.Feature.Text.rStatusKeyTypeText, rowBody: keyStatusText, textColor: apiTextColor)
                    
                    let authTextColor: Color = radarModel.permissionsModel.permissionStatus.isRestrictedPermission ? Color.red : Color.black
                    RadarStatusRow(rowTitle: Constants.Design.Feature.Text.rStatusAuthStatusText, rowBody: radarModel.permissionsModel.permissionStatus.description, textColor: authTextColor)
                    RadarStatusRow(rowTitle: Constants.Design.Feature.Text.rStatusUserNameText, rowBody: radarModel.radarUserId, textColor: .black)
                }
                Divider()
                Spacer()
                HStack{
                    Spacer()
                    Button(action: {
                        activeAppType = .Settings
                    }) {
                        Text(Constants.Design.Feature.Text.bCustomizeText)
                            .padding(bCustomizePadding)
                    }
                    .background(Color.primaryColor)
                    .foregroundColor(Color.white)
                    .cornerRadius(bCustomizeRadius)
                    Spacer()
                }
            }
        }
    }
}

struct FeatureView_Previews: PreviewProvider {
    static let radarModel : RadarModel = RadarModel()
    
    static var previews: some View {
        FeatureView()
            .environmentObject(radarModel)
    }
}
