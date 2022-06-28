//
//  ViewChangeButton.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 6/27/22.
//

import SwiftUI

struct ViewChangeButton: View {
    @Binding var activeFeatureBinding: QSRFeatures?
    
    var buttonActivatedFeature: QSRFeatures
    var buttonText: String
    
    var body: some View {
        Button(action: {
            activeFeatureBinding = buttonActivatedFeature
        }) {
            Text(buttonText)
                .padding(10)
        }
            .frame(width:Constants.screenWidth)
            .background(Color.primaryColor)
            .foregroundColor(Color.white)
    }
}
