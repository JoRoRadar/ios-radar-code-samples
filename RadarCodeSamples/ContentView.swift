//
//  ContentView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var radarModel : RadarModel
    
    @State private var textFieldInput: String = ""
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Autocomplete")
                .bold()
                .padding()
            TextField("Search Geofences", text: $textFieldInput)
                .onChange(of: textFieldInput) { newValue in
                    //Generate new suggestions on each keystroke
                    radarModel.generateAutocompleteSuggestions(textInput: newValue)
                }
                .onSubmit {
                    //Search for geofences near address input.
                    radarModel.searchForGeofencesNearAddress(textInput: textFieldInput)
                }
            List {
                ForEach(radarModel.autocompleteSuggestions, id: \.self) { suggestion in
                    CustomButton(title: suggestion, textFieldInput: $textFieldInput)
                }
            }
        }
    }
}

/**
 We create a custom button for this example as an simple way to update the TextField input based on autocomplete results.
 */
struct CustomButton: View {
    let title: String
    @Binding var textFieldInput: String
    
    var body: some View {
        Button(action:{
            textFieldInput = self.title
        }){
            Text(title)
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
