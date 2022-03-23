//
//  ContentView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var textFieldInput: String = ""
    @EnvironmentObject var radarModel : RadarModel
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Autocomplete")
                .bold()
                .padding()
            TextField("Search Geofences", text: $textFieldInput)
                .onChange(of: textFieldInput) { newValue in
                    radarModel.generateAutocompleteSuggestions(textInput: newValue)
                }
                .onSubmit {
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
