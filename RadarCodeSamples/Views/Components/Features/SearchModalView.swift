//
//  SearchModalView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 6/27/22.
//

import SwiftUI
import MapKit
import RadarSDK

struct SearchModalView: View {
    
    @EnvironmentObject var radarModel : RadarModel

    @Binding var searchModalVisible: Bool
    @Binding var confirmedAddress: RadarAddress?
    
    @State private var textFieldInput: String = ""
    
    let searchFieldInsets  = EdgeInsets(top:3, leading: 5, bottom:3, trailing: 5)
    
    var body: some View {
        VStack{
            TextField(Constants.Design.NearbyLocator.Text.sAddressFieldInputPrompt , text: $textFieldInput )
               .onChange(of: textFieldInput){
                   
                   /// Capture every keystroke with Radar to populate autocomplete suggestions.
                   radarModel.generateAutocompleteSuggestions(textInput: $0)
               }
               .textInputAutocapitalization(.never)
               .disableAutocorrection(false)
               .frame(width:Constants.screenWidth)
               .padding(searchFieldInsets)
            Divider()
                .background(Color.primaryColor)
                .frame(width:Constants.screenWidth)
                .padding(searchFieldInsets)
            SearchResultsView(searchModalVisible: $searchModalVisible, confirmedAddress: $confirmedAddress, autoCompleteSuggestions: radarModel.autocompleteStatus.autocompleteSuggestions)
            Spacer()
        }
    }
}

struct SearchResultsView: View {
    
    @Binding var searchModalVisible: Bool
    @Binding var confirmedAddress: RadarAddress?
    
    var autoCompleteSuggestions:[RadarAddress]
    
    var body: some View {
        ScrollView{
            VStack{
                ForEach(autoCompleteSuggestions, id: \.self){ address in
                    SearchResultsCell(
                        searchModalVisible: $searchModalVisible,
                        confirmedAddress: $confirmedAddress,
                        radarAddress: address
                    )
                }
            }
            .background(Color.backgroundShaderColor)
        }
    }
}


struct SearchResultsCell: View{
    
    @Binding var searchModalVisible: Bool
    @Binding var confirmedAddress: RadarAddress?
    
    let radarAddress: RadarAddress
    
    let cellImageSize: CGFloat = 25
    let viewInsets  = EdgeInsets(top:3, leading: 5, bottom:3, trailing: 5)
    
    var body: some View {
        VStack{
            Divider()
            HStack{
                Image(systemName: Constants.Design.NearbyLocator.Image.searchAddressSelectorImg)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cellImageSize, height: cellImageSize)
                    .padding()
                    .foregroundColor(Color.primaryColor)
                Divider()
                Spacer()
                Text(radarAddress.formattedAddress ?? Constants.Design.NearbyLocator.Text.locationAddressDataUnavailable)
                    .font(.headline)
                Spacer()
            }
                .frame(minWidth: Constants.screenWidth, alignment: .leading)
            Divider()
        }
        .background(Color.white)
        .padding(viewInsets)
        .onTapGesture {
            confirmedAddress = radarAddress
            searchModalVisible = false
        }
    }
}
