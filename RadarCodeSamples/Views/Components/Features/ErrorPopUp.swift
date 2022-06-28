//
//  ErrorPopUp.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 6/21/22.
//

import SwiftUI

struct ErrorPopUp : View {
    
    let errorButtonHeight:CGFloat = 50
    
    var body: some View{
        VStack{
            Spacer()
            Text(Constants.Design.QSR.Text.qPickupErrorMessageText)
                .fontWeight(.medium)
                .frame(width:Constants.screenWidth, height: errorButtonHeight)
                .background(.red)
        }
    }
}

struct ErrorPopUp_Previews: PreviewProvider {
    static var previews: some View {
        ErrorPopUp()
    }
}
