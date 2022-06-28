//
//  AppConstants.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 5/24/22.
//

import Foundation
import SwiftUI

extension Color {
    static let primaryColor = Color(red: 0.0, green: 0.4874, blue: 1.00)
    static let secondaryColor = Color(red: 0.0, green: 1.00, blue: 0.698)
    static let accentColor = Color(red: 0.09, green: 0.0, blue: 1.00)
    static let primaryShadowColor = Color(red: 0.151, green: 0.157, blue: 0.166, opacity: 0.100)
    static let backgroundShaderColor = Color(.displayP3, red: 0.240, green: 0.240, blue: 0.240, opacity: 0.1)
}


struct Constants{
    
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    
    struct Radar {
        struct Defaults{
            static let rUserName = "SampleUser"
            static let rUserDescription = "This is a radar user created from the Radar Code Samples repo"
            static let rUserMetadata = ["IsTestUser": true]
            
            static let rGeofenceTag = "QSR"
            
            static let rDefaultSearchRadius: Int32 = 10000
        }
        struct MetadataKeys {
            static let storeHoursOpeningKey = "store_hours_opening"
            static let storeHoursClosingKey = "store_hours_closing"
            
            static let storeAddressKey = "store_address"
            
            static let hasCurbsideKey = "has_curbside"
        }
    }
    struct Design {
        struct Primary {
            struct Image {
                static let radarLogoImage = "Radar_Logo"
                static let radarSubtitleImage = "Radar_Sub_Title"
            }
            
            struct Text {
                static let rKeyTypeTextProd = "Production"
                static let rKeyTypeTextDev = "Test"
            }
        }
        struct QSR {
            
            struct Text{
                static let qNavigationTitle = "Main Menu"
                
                static let bNearbyLocation = "Find Nearby Locations"
                
                static let qFoodItemTitle = "Menu"
                
                static let qPickupLocationTitle = "Pickup Location"
                static let qPickerTitle = "Location"
                static let qPickupLocationDefaultText = "Retrieving Locations..."
                static let qPickupLocationFallbackText = "No locations found in area"
                
                static let qPickupErrorMessageText = "Pickup location must be selected"
            }
            
            struct Image {
                static let bPlaceOrderSysImg = "chevron.right.circle"
            }
            struct Menu {
                static let qFoodItem1Name = "Burger"
                static let qFoodItem1Image = "App_Icon_Food"
                static let qFoodItem1Description = "Tasty cheeseburger and fries"
                
                static let item1 = [
                    "name": qFoodItem1Name,
                    "image": qFoodItem1Image,
                    "description": qFoodItem1Description
                    ]
                
                static let items = [item1]
            }
        }
        
        struct NearbyLocator {
            struct Text {
                static let nNavigationTitle = "Nearby Locations"
                
                static let nResultsTitle = "Nearby Locations"
                
                static let locationFallbackHours = "Hours not available"
                static let locationFeatureFallback = "Curbside may not be available"
                
                static let locationAddressFallback = "No address available"
                
                static let locationFeatureAvailable = "Curbside is available at this location"
                static let locationFeatureNotAvailable = "Curbside is not available at this location"
                
                static let locationAddressDataUnavailable = "Network Error"
                
                static let sAddressFieldInputPrompt = "Search for address, city, or zip"
            }
            
            struct Image {
                static let mapPinSysImg = "mappin.circle"
                
                static let searchAddressToolbarImg = "magnifyingglass.circle"
                static let searchAddressSelectorImg = "arrow.right"
                
                static let mapDisplayGeofencePinImg_0 = "mappin.circle.fill"
                static let mapDisplayGeofencePinImg_1 = "arrowtriangle.down.fill"
                static let mapDisplayDummyPinImg = "mappin"
            }
        }
        struct Tracking {
            struct Text {
                static let tNavigationTitle = "Order Pickup"
                
                static let bSwapViewsText = "Tap to Swap Views"
                
                static let jTitleText = "Journey"
                static let jNearestStoreText = "Closest Store: "
                
                static let jExpectedArrivalText = "Expected Arrival: "
                static let jExpectedArrivalFallbackText = "..."
                
                static let jArrivedText = "We see you've arrived. Please press the button to complete the trip and we will shutdown tracking services."
                static let bTripComplete = "Trip Complete"
                
                static let jManualText = "When you are on your way to the store, please click the button below to begin your trip. When you arrive your fold will be hot and ready to go!"
                static let bManual = "On my way!"
                
                static let jStartedState = "Started"
                static let jApproachingState = "Approaching"
                static let jArrivedState = "Arrived"
                static let jCompletedState = "Completed"
            }
            
            struct Image {
                static let bSwapViewsMapSysImg = "square.and.line.vertical.and.square.filled"
                static let bSwapViewsDefaultSysImg = "square.filled.and.line.vertical.and.square"
                
                static let bSwapViewDefaultSysImage = "car.circle"
                
                static let bTripCompleteSysImage = "checkmark"
                
                static let bManualTripSysImg = "figure.walk"
                
                static let jStateCurrentFilledSysImg = "checkmark.circle.fill"
                static let jStateFilledSysImg = "circle.fill"
                static let jStateNotFilledSysImg = "circle"
                
            }
        }
    }
}
