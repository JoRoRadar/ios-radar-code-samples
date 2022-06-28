//
//  ButtonStyles.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 6/27/22.
//

import SwiftUI

struct ItemButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .background(configuration.isPressed ? Color.primaryColor : .white)
    }
}

struct PrimaryColorButtonStyle: ButtonStyle{
    
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .background(configuration.isPressed ? .white : Color.primaryColor)
            .foregroundColor(configuration.isPressed ? Color.primaryColor : .black)
    }
}
