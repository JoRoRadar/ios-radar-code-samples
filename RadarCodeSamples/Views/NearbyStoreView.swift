//
//  NearbyStoreView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 5/11/22.
//

import SwiftUI
import MapKit

struct NearbyStoreView: View {
    
    @EnvironmentObject var radarModel : RadarModel

    let mapFrameHeightMultiplier : CGFloat = 0.4
    
    var body: some View {
        Divider()
            .navigationBarTitle(Constants.Design.NearbyLocator.Text.nNavigationTitle, displayMode: .inline)
            .onAppear{
                radarModel.updateRegion()
                radarModel.findNearbyLocations(appType: AppManager.shared.appType)
            }
        VStack{
            //Focus map on location data sent to Radar.
            Map(coordinateRegion: $radarModel.currentRegion,
                showsUserLocation: true,
                annotationItems: radarModel.nearbyGeofences
            ){ place in
                MapPin(coordinate: place.location, tint: Color.primaryColor)
            }
            .frame(width: Constants.screenWidth, height: Constants.screenHeight * mapFrameHeightMultiplier, alignment: .top)
            Text(Constants.Design.NearbyLocator.Text.nResultsTitle)
            Divider()
            ScrollView{
                VStack{
                    if radarModel.nearbyGeofences.count > 0 {
                        ForEach(radarModel.nearbyGeofences, id: \.self){ geofence in
                            LocationCell(geofence: geofence)
                        }
                    }
                }
            }
        }
    }
}

// MARK: Radar Connected Views

struct LocationCell: View{
    
    var geofence: IdentifiableGeofence
    
    let cellImageSize: CGFloat = 50
    
    private var storeHoursString = Constants.Design.NearbyLocator.Text.locationFallbackHours
    private var storeFeaturesString = Constants.Design.NearbyLocator.Text.locationFeatureFallback
    private var storeAddressString = Constants.Design.NearbyLocator.Text.locationAddressFallback
    
    init(geofence:IdentifiableGeofence){
        
        //Unpack all metadata from geofence.
        self.geofence = geofence
        
        let storeHoursOpeningKey = Constants.Radar.MetadataKeys.storeHoursOpeningKey
        let storeHoursClosingKey = Constants.Radar.MetadataKeys.storeHoursClosingKey
        
        let storeAddressKey = Constants.Radar.MetadataKeys.storeAddressKey
        
        let hasCurbsideKey = Constants.Radar.MetadataKeys.hasCurbsideKey
        
        if( geofence.metadata[storeHoursOpeningKey] != nil && geofence.metadata[storeHoursClosingKey] != nil){
            let storeOpening = geofence.metadata[storeHoursOpeningKey]! as! String
            let storeClosing = geofence.metadata[storeHoursClosingKey]! as! String
            storeHoursString = "Store hours: \(storeOpening) - \(storeClosing)"
        }
        if geofence.metadata[hasCurbsideKey] != nil{
            storeFeaturesString = geofence.metadata[hasCurbsideKey]! as! Bool ? Constants.Design.NearbyLocator.Text.locationFeatureAvailable : Constants.Design.NearbyLocator.Text.locationFeatureNotAvailable
        }
        if geofence.metadata[storeAddressKey] != nil{
            storeAddressString = geofence.metadata[storeAddressKey]! as! String
        }
    }
    
    var body: some View{
        VStack{
            Divider()
            HStack{
                Image(systemName: Constants.Design.NearbyLocator.Image.mapPinSysImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cellImageSize, height: cellImageSize)
                    .padding()
                    .foregroundColor(Color.primaryColor)
                Divider()
                LocationDataView(
                    storeDescription: geofence.description,
                    storeHoursString: storeHoursString,
                    storeAddressString: storeAddressString,
                    storeFeaturesString: storeFeaturesString)
                    .frame(maxWidth: .infinity)
            }
                .frame(minWidth: Constants.screenWidth, alignment: .leading)
            Divider()
        }
    }
}


// MARK: Supporting Views

struct LocationDataView: View {
    
    var storeDescription: String
    
    var storeHoursString:String
    var storeAddressString: String
    var storeFeaturesString: String
    
    let cellFontSize: CGFloat = 20
    
    var body: some View{
        VStack{
            Text(storeDescription)
                .font(.system(size: cellFontSize))
                .fontWeight(.bold)
                .frame(alignment: .center)
                .padding()
            Spacer()
            VStack{
                Text(storeHoursString)
                    .fontWeight(.regular)
                Text(storeAddressString)
                    .fontWeight(.regular)
                Text(storeFeaturesString)
                    .fontWeight(.ultraLight)
            }
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct NearbyStoreView_Previews: PreviewProvider {
    static let radarModel : RadarModel = RadarModel()
    
    static var previews: some View {
        NearbyStoreView()
            .environmentObject(radarModel)
    }
}
