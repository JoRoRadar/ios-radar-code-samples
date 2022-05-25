//
//  ShoppingView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 5/3/22.
//

import SwiftUI

//Identify what view is being shown/pushed on stack.
enum QSRFeatures {
    case CART
    case NEARBY
    case CHECKOUT
    case TRIP
}

struct MenuView: View {
    
    @EnvironmentObject var radarModel : RadarModel
    
    @State var activeFeature:QSRFeatures? = .CART
    @State var totalItemsInCart:Int = 0
    @State var showCheckoutButton:Bool = false
    
    @State private var selectedGeofence : IdentifiableGeofence?
    
    @State var showPicker: Bool = false
    @State var pickerId = 0
    
    let checkoutButtonAnimationDuration : CGFloat = 1
    
    var body: some View {
        NavigationViews(activeFeature: $activeFeature, selectedGeofence: $selectedGeofence, radarModel: radarModel)
            .navigationBarTitle(Constants.Design.QSR.Text.qNavigationTitle, displayMode: .inline)
            .onAppear{
                AppManager.shared.appType = .QSR
            }
        VStack{
            Divider()
            LaunchNearbyLocatorView(activeFeature: $activeFeature)
            CarouselView()
            
            //Setup Picker for chosing a nearby Radar geofence for pickup location.
            LocationPicker(selectedGeofence: $selectedGeofence, radarModel: radarModel)

            Divider()
            Text(Constants.Design.QSR.Text.qFoodItemTitle)
                .fontWeight(.bold)
            Divider()
            ZStack{
                MenuItemView(totalItemsInCart: $totalItemsInCart, showCheckoutButton: $showCheckoutButton)
                    .zIndex(1)

                //Setup 'Proceed to Checkout' and 'Error Message' views.
                if showCheckoutButton && selectedGeofence != nil{
                    
                    CheckoutButton(activeFeature: $activeFeature, totalItemsInCart: $totalItemsInCart)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut(duration: checkoutButtonAnimationDuration))
                        .zIndex(2)
                }else if showCheckoutButton && selectedGeofence == nil {
                    ErrorMessageView()
                        .transition(.move(edge:.bottom))
                        .animation(.easeInOut(duration: checkoutButtonAnimationDuration))
                        .zIndex(3)
                        .onAppear(){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCheckoutButton = false
                            }
                        }
                }
            }
        }
    }
    
    struct NavigationViews : View {
        
        @Binding var activeFeature: QSRFeatures?
        @Binding var selectedGeofence : IdentifiableGeofence?
        
        var radarModel: RadarModel
        
        var body: some View{
            NavigationLink(
                destination: NearbyStoreView().environmentObject(radarModel),
                tag: QSRFeatures.NEARBY,
                selection: $activeFeature)
            { EmptyView() }
            
            //Navigation links auto unwrap on creation. Need to signal the unwrap behavior.
            if selectedGeofence != nil{
                NavigationLink(
                    destination: TrackingView(selectedGeofence: Binding($selectedGeofence)!).environmentObject(radarModel),
                    tag: QSRFeatures.CHECKOUT,
                    selection: $activeFeature)
                { EmptyView() }
            }
        }
    }
}

// MARK: Supporting Views

struct LaunchNearbyLocatorView: View {
    
    @Binding var activeFeature: QSRFeatures?
    
    var body: some View {
        Button(action: {
            activeFeature = .NEARBY
        }) {
            Text(Constants.Design.QSR.Text.bNearbyLocation)
                .padding(10)
        }
            .frame(width:Constants.screenWidth)
            .background(Color.primaryColor)
            .foregroundColor(Color.white)
    }
}

struct CarouselView: View  {
    
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

struct ErrorMessageView : View {
    
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

struct CheckoutButton: View {
    
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

struct MenuItemView: View {
    
    @Binding var totalItemsInCart: Int
    @Binding var showCheckoutButton: Bool
    
    var body: some View{
        ScrollView{
            LazyVStack{
                ForEach(1...5, id: \.self){ index in
                    ItemButton(cartTotal: $totalItemsInCart, showCheckoutButton: $showCheckoutButton, selectedItem: Constants.Design.QSR.Menu.items.randomElement()!)
                }
            }
            .background(Color.backgroundShaderColor)
        }
    }
}

struct ItemButton: View {
    
    @Binding var cartTotal: Int
    @Binding var showCheckoutButton : Bool
    
    var selectedItem: Dictionary<String,String>
    
    let buttonFrameHeight : CGFloat = 50
    let imageSize : CGFloat = 50
    let imagePadding : CGFloat = 5
    
    let viewInsets  = EdgeInsets(top:3, leading: 5, bottom:3, trailing: 5)
    let viewBorderWidth :CGFloat = 0.5
    
    var body: some View{
        ZStack{
            Button(action: {
                showCheckoutButton = true
                cartTotal += 1
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
// MARK: Radar Connected Views

struct LocationPicker: View{
    
    @Binding var selectedGeofence : IdentifiableGeofence?
    
    @State var defaultLocationText:String = Constants.Design.QSR.Text.qPickupLocationDefaultText
    @State private var showPicker: Bool = false
    
    var radarModel: RadarModel
    
    let frameHeight: CGFloat = 50
    let asyncWaitPeriod: CGFloat = 4
    
    var body: some View{
        if( showPicker ){
            HStack{
                Text(Constants.Design.QSR.Text.qPickupLocationTitle)
                Divider()
                Picker(Constants.Design.QSR.Text.qPickerTitle, selection:Binding($selectedGeofence)!){
                    ForEach(radarModel.nearbyGeofences, id: \.self){ geofence in
                        Text(geofence.description).tag(geofence)
                    }
                }
            }
            .frame(width: Constants.screenWidth, height: frameHeight)
        }else{
            Text(defaultLocationText)
                .frame(width: Constants.screenWidth, height: frameHeight)
                .onAppear(){
                    self.updatePickerValues()
                }
        }
    }
    
    // MARK: Helper ASYNC Functions
    
    func updatePickerValues(){
        //Allow for Radar callbacks to complete
        self.radarModel.findNearbyLocations(appType: .QSR)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + asyncWaitPeriod) {
            if self.radarModel.nearbyGeofences.count == 0{
                defaultLocationText = Constants.Design.QSR.Text.qPickupLocationFallbackText
                self.updatePickerValues()
            }else{
                showPicker = true
                selectedGeofence = radarModel.nearbyGeofences[0]
            }
        }
    }
}

// MARK: Styles

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

struct MenuView_Previews: PreviewProvider {
    static let radarModel : RadarModel = RadarModel()
    
    static var previews: some View {
        MenuView()
            .environmentObject(radarModel)
    }
}
