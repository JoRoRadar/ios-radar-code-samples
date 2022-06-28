//
//  NearbyStoreView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 5/11/22.
//

import SwiftUI
import MapKit
import RadarSDK

struct NearbyStoreView: View {
    
    @EnvironmentObject var radarModel : RadarModel

    @State var searchModalVisible: Bool = false
    @State var searchAddress: RadarAddress? = nil
    
    let mapFrameHeightMultiplier : CGFloat = 0.4
    
    var body: some View {
        VStack{
            Divider()
                .navigationBarTitle(Constants.Design.NearbyLocator.Text.nNavigationTitle, displayMode: .inline)
                .toolbar {
                    ToolbarItem( placement: .navigationBarTrailing){
                        ToolbarButtonView
                    }
                }
                .onAppear{
                    radarModel.updateRegion()
                    radarModel.findNearbyLocations()
                }
            
            
            if self.searchModalVisible {
                /// RADAR POWERED: Open the 'Autocomplete' Feature.
                SearchModalView(searchModalVisible: $searchModalVisible, confirmedAddress: $searchAddress)
                    .environmentObject(radarModel)
            }else{
                /// Display nearby locations based on either the users location or an address searched for in the 'Autocomplete' feature.
                
                // TODO: Special handling when location permissions are disabled.
                MapDisplayView(mapableGeofences: $radarModel.geofenceSearchStatus.nearbyGeofences, coordinateRegion: $radarModel.currentRegion)
                    .frame(width: Constants.screenWidth, height: Constants.screenHeight * mapFrameHeightMultiplier, alignment: .top)
                if (self.searchAddress != nil){
                    Text(self.searchAddress!.addressLabel ?? Constants.Design.NearbyLocator.Text.locationAddressDataUnavailable )
                        .onAppear{
                            radarModel.findNearbyLocations(address: self.searchAddress)
                        }
                }else{
                    Text(Constants.Design.NearbyLocator.Text.nResultsTitle)
                }
                Divider()
                ScrollView{
                    VStack{
                        if radarModel.geofenceSearchStatus.nearbyGeofences.count > 0 {
                            ForEach(radarModel.geofenceSearchStatus.nearbyGeofences, id: \.self){ geofence in
                                // The Dummy flag indicates that a pin needs to be added to the map but it is not a valid Radar geofence to present the user as a store option. This flag is not present on the base RadarGeofence class.
                                if !geofence.isDummy {
                                    LocationCell(radarModel: self.radarModel, geofence: geofence)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    ///
    /// View Sections
    ///
    
    var ToolbarButtonView: some View{
        Button(action: {
            if( self.searchModalVisible ){
                self.searchModalVisible = false
                radarModel.updateRegion()
                radarModel.findNearbyLocations()
            }else{
                self.searchModalVisible = true
                self.searchAddress = nil
            }
        }) {
            Image(systemName: Constants.Design.NearbyLocator.Image.searchAddressToolbarImg)
                .renderingMode(.original)
                .foregroundColor(.primaryColor)
        }
    }
}

// MARK: Radar Connected Views

struct LocationCell: View{
    
    var radarModel: RadarModel
    var geofence: IdentifiableGeofence
    
    let cellImageSize: CGFloat = 50
    
    private var storeHoursString = Constants.Design.NearbyLocator.Text.locationFallbackHours
    private var storeFeaturesString = Constants.Design.NearbyLocator.Text.locationFeatureFallback
    private var storeAddressString = Constants.Design.NearbyLocator.Text.locationAddressFallback
    
    init(radarModel: RadarModel, geofence:IdentifiableGeofence){
        
        self.radarModel = radarModel
        
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
        .onTapGesture {
            radarModel.currentRegion = MKCoordinateRegion(
                center: geofence.location,
                latitudinalMeters: 100,
                longitudinalMeters: 100
            )
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
