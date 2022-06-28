//
//  MenuView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 6/21/22.
//

import SwiftUI

struct MenuView: View {
    @Binding var itemCountBinding: Int
    @Binding var validCartFlagBinding: Bool
    
    var body: some View{
        ScrollView{
            LazyVStack{
                ForEach(1...5, id: \.self){ index in
                    ItemButton(itemCountBinding: $itemCountBinding, validCartFlagBinding: $validCartFlagBinding, selectedItem: Constants.Design.QSR.Menu.items.randomElement()!)
                }
            }
            .background(Color.backgroundShaderColor)
        }
    }
}

struct ItemButton: View {
    
    @Binding var itemCountBinding: Int
    @Binding var validCartFlagBinding : Bool
    
    var selectedItem: Dictionary<String,String>
    
    let buttonFrameHeight : CGFloat = 50
    let imageSize : CGFloat = 50
    let imagePadding : CGFloat = 5
    
    let viewInsets  = EdgeInsets(top:3, leading: 5, bottom:3, trailing: 5)
    let viewBorderWidth :CGFloat = 0.5
    
    var body: some View{
        ZStack{
            Button(action: {
                validCartFlagBinding = true
                itemCountBinding += 1
            }){
                //Button size framing
                Text("")
                    .frame(minWidth: Constants.screenWidth, minHeight: buttonFrameHeight)
            }
            .buttonStyle(ItemButtonStyle())
            HStack{
                Image(selectedItem["image"]!)
                    .resizable()
                    .frame(width: imageSize, height: imageSize, alignment: .leading)
                    .padding([.leading],imagePadding)
                Divider()
                VStack(alignment: .leading){
                    Text(selectedItem["name"]!)
                        .fontWeight(.heavy)
                    Text(selectedItem["description"]!)
                        .fontWeight(.ultraLight)
                }
                Spacer()
            }
        }
        .padding(viewInsets)
        .border(.gray, width:viewBorderWidth)
        .background(Color.white)
    }
}
