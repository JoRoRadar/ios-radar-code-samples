//
//  ImageCarousel.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 6/21/22.
//

import SwiftUI

struct ImageCarousel: View  {
    
    var body: some View {
        ScrollView(.horizontal){
            ScrollViewReader { proxy in
                HStack{
                    ForEach(1...4, id: \.self) { index in
                        CarouselItem(itemImage: Constants.Design.QSR.Menu.items.randomElement()!["image"]!)
                            .padding()
                    }
                }
            }
        }
        .background(Color.backgroundShaderColor)
        
    }
}

struct CarouselItem: View{

    let itemImage : String

    var body: some View{
        ZStack{
            Image(itemImage)
                .resizable()
                .scaledToFit()
        }
        .frame(width: Constants.screenWidth, height: Constants.screenHeight/3, alignment: .center)
    }
}

struct ImageCarousel_Previews: PreviewProvider {
    static var previews: some View {
        ImageCarousel()
    }
}
