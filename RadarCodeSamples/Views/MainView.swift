//
//  Main.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 6/21/22.
//

import SwiftUI

/// Used to Identify App State
enum QSRFeatures {
    case CART
    case NEARBY
    case CHECKOUT
    case TRIP
}

struct MainView: View {
    
    @EnvironmentObject var radarModel : RadarModel
    
    @State var activeFeature:QSRFeatures? = .CART
    @State var totalItemsInCart:Int = 0
    @State var showCheckoutButton:Bool = false
    
    @State private var selectedGeofence : IdentifiableGeofence?
    
    @State var showPicker: Bool = false
    @State var pickerId = 0
    
    let checkoutButtonAnimationDuration : CGFloat = 1
    
    var body: some View {
        NavigationView{
            VStack{
                NavigationViews(activeFeature: $activeFeature, selectedGeofence: $selectedGeofence, radarModel: radarModel)
                    .navigationBarTitle(Constants.Design.QSR.Text.qNavigationTitle, displayMode: .inline)
                Divider()
                
                /// RADAR POWERED: Open the 'Store Locator' Feature.
                ViewChangeButton(activeFeatureBinding: $activeFeature, buttonActivatedFeature: .NEARBY, buttonText: Constants.Design.QSR.Text.bNearbyLocation )
                ImageCarousel()
                
                /// RADAR POWERED: Present the user with nearby stores for pickup.
                // TODO: Special handling when location is disabled.
                GeofencePicker(selectedGeofence: $selectedGeofence, radarModel: radarModel)
                
                Divider()
                Text(Constants.Design.QSR.Text.qFoodItemTitle)
                    .fontWeight(.bold)
                Divider()
                
                ZStack{
                    /// Transition between Checkout and Error states specific to the menu screen.
                    ///
                    /// Due to the app journey being limited, a user must satisfy the criteria of having both picked
                    /// a location for food pickup & have at least 1 item in their cart. Having an item without a location picked
                    /// or nearby would lead to an error.
                    MenuView(itemCountBinding: $totalItemsInCart, validCartFlagBinding: $showCheckoutButton)
                        .zIndex(1)

                    //Setup 'Proceed to Checkout' and 'Error Message' views.
                    if showCheckoutButton && selectedGeofence != nil{

                        CheckoutButtonBottom(activeFeature: $activeFeature, totalItemsInCart: $totalItemsInCart)
                            .transition(.move(edge: .bottom))
                            .animation(.easeInOut(duration: checkoutButtonAnimationDuration))
                            .zIndex(2)
                    }else if showCheckoutButton && selectedGeofence == nil {
                        ErrorPopUp()
                            .transition(.move(edge:.bottom))
                            .animation(.easeInOut(duration: checkoutButtonAnimationDuration))
                            .zIndex(3)
                            .onAppear(){
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showCheckoutButton = false
                                }
                            }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    
    /// Enable Navigation Views to be programmatically transitioned between.
    ///
    /// The Main View can transition between a nearby/store locator and the Trip Tracking/Curbside Pickup
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
                    destination: TrackingView(selectedGeofence: selectedGeofence!).environmentObject(radarModel),
                    tag: QSRFeatures.CHECKOUT,
                    selection: $activeFeature)
                { EmptyView() }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static let radarModel : RadarModel = RadarModel()
    
    static var previews: some View {
        MainView()
            .environmentObject(radarModel)
    }
}
