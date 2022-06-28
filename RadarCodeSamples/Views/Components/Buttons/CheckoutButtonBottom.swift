//
//  CTAButtonBottom.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 6/21/22.
//

import SwiftUI

struct CheckoutButtonBottom: View {
    @Binding var activeFeature: QSRFeatures?
    @Binding var totalItemsInCart: Int
    
    let checkoutButtonHeight: CGFloat = 50
    
    var body: some View {
        VStack{
            Spacer()
            Button(action:{
                activeFeature = .CHECKOUT
            }){
                Label("Place Order : \(totalItemsInCart) Item(s)", systemImage: Constants.Design.QSR.Image.bPlaceOrderSysImg)
                    .frame(width: Constants.screenWidth, height: checkoutButtonHeight, alignment: .center)
            }
            .buttonStyle(PrimaryColorButtonStyle())
        }
    }
}
