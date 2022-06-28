//
//  RadarModel.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import Foundation
import RadarSDK
import MapKit
import SwiftUI

class RadarModel: NSObject, RadarDelegate, ObservableObject {
    
    @Published var radarUserId: String = Constants.Radar.Defaults.rUserName
    
    @Published var isBackgroundTracking = false
    
    @Published var currentRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 30, longitude: -122), latitudinalMeters: 1000, longitudinalMeters: 1000)
    
    @Published var autocompleteStatus: AutocompleteStatus = AutocompleteStatus()
    @Published var geofenceSearchStatus: GeofenceSearchStatus = GeofenceSearchStatus()
    @Published var tripTrackingStatus: TripTrackingStatus = TripTrackingStatus()
    
    var radarAPIKeyType: String = Constants.Design.Primary.Text.rKeyTypeTextProd
    
    var permissionsModel = PermissionsModel()
    
    let defaultBackgroundTrackingOption = RadarTrackingOptions.presetContinuous
    
    let radarGeofenceSearchRadius:Int32 = Constants.Radar.Defaults.rDefaultSearchRadius
    let geofenceTag: String = Constants.Radar.Defaults.rGeofenceTag
    
    /// Status of all running async requests
    
    struct AutocompleteStatus {
        var autocompleteSuggestions: [RadarAddress] = []
        
        var debounceTimer : Timer? // A timer is leveraged to ensure we are throttling API requests.
    }
    
    override init(){
        super.init()
        
        Radar.setDelegate(self)
        
        Radar.setUserId(radarUserId)
        Radar.setDescription(Constants.Radar.Defaults.rUserDescription)
        
        Radar.setMetadata( Constants.Radar.Defaults.rUserMetadata)
        self.updateRegion()
    }
    
    // MARK: Generic Functions for UI
    
    //Update the users region for presentation in a Map View.
    func updateRegion(){
        Radar.trackOnce { (status: RadarStatus, location: CLLocation?, events: [RadarEvent]?, user: RadarUser?) in
            guard status == .success, let location = location else{
                self.currentRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.73566, longitude: -73.99048), latitudinalMeters: 1000, longitudinalMeters: 1000)
                return
            }
            
            self.currentRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        }
    }
    
    // MARK: Trip Tracking
    
    struct TripTrackingStatus {
        var isOnTrip: Bool = false
        var tripStatus: RadarTripStatus = .unknown
        var expectedJourneyRemaining: Int?
    }
    
    func startTripForSelectedLocation(selectedGeofence:IdentifiableGeofence){
        
        if self.tripTrackingStatus.isOnTrip{
            return
        }
        
        let tripOptions = RadarTripOptions(
            externalId: "Sample App Trip \(Int.random(in: 100..<1000))",
            destinationGeofenceTag: selectedGeofence.tag,
            destinationGeofenceExternalId: selectedGeofence.externalId)
        
        tripOptions.mode = .car
        tripOptions.metadata = [
          "Customer Name": "Jacob Pena",
          "Car Model": "Green Honda Civic"
        ]
        
        Radar.startTrip(options: tripOptions)
        Radar.startTracking(trackingOptions: .presetContinuous)
        
        self.tripTrackingStatus.tripStatus = .started
        self.tripTrackingStatus.isOnTrip = true
    }
    
    func completeCurrentTrip(){
        Radar.completeTrip()
        Radar.stopTracking()
        self.tripTrackingStatus.tripStatus = .completed
        self.tripTrackingStatus.isOnTrip = false
    }
    
    
    // MARK: Store Locator
    
    struct GeofenceSearchStatus {
        var isRunningNearbySearch: Bool = false
        var nearbyGeofences: [IdentifiableGeofence] = []
    }
    
    /// Support searching for goefences near the users current location and an address that has been manually entered.
    func findNearbyLocations(address:RadarAddress? = nil) {
        
        if self.geofenceSearchStatus.isRunningNearbySearch {
            return
        }
        
        self.geofenceSearchStatus.isRunningNearbySearch = true
        
        if address != nil {
            let radarAddress = address!
            
            let location = CLLocation(latitude: radarAddress.coordinate.latitude, longitude: radarAddress.coordinate.longitude)
            self.currentRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            
            Radar.searchGeofences(near: location, radius: self.radarGeofenceSearchRadius, tags: [self.geofenceTag], metadata: nil, limit: 10){(status:RadarStatus, location: CLLocation?, geofences: [RadarGeofence]? ) in
                
                self.geofenceSearchStatus.isRunningNearbySearch = false
                
                guard status == .success, let geofences = geofences else {
                    return
                }
                
                self.updateNearbyGeofences(geofences: geofences, additionalMarkers: [radarAddress.coordinate])
            }
        }else{
            Radar.searchGeofences(radius: self.radarGeofenceSearchRadius, tags: [self.geofenceTag], metadata: nil, limit: 10) { (status:RadarStatus, location: CLLocation?, geofences: [RadarGeofence]? ) in
                
                self.geofenceSearchStatus.isRunningNearbySearch = false
                
                guard status == .success, let geofences = geofences else {
                    return
                }
                
                self.updateNearbyGeofences(geofences: geofences)
            }
        }
    }
    
    func updateNearbyGeofences(geofences: [RadarGeofence], additionalMarkers: [CLLocationCoordinate2D]? = nil){
        self.geofenceSearchStatus.nearbyGeofences = []
        
        for geofence in geofences {
            self.geofenceSearchStatus.nearbyGeofences.append(IdentifiableGeofence(geofence: geofence))
        }
        
        if additionalMarkers != nil {
            for marker in additionalMarkers! {
                self.geofenceSearchStatus.nearbyGeofences.append(IdentifiableGeofence(coordinate: marker))
            }
        }
    }
    
    // MARK: Autocomplete Search Results
    
    /// Make responsive autocomplete requests as it relates to a stream of keystrokes minding rate limiting.
    ///
    /// It is important to throttle the requests to any API and as such keystrokes for addresses tend to be pretty demanding. A proper user experience
    /// will only make requests in an attempt to aid the users search. Waiting for a keystroke pause is a perfect indicator of when the user is looking for
    /// assistance.
    func generateAutocompleteSuggestions(textInput: String){
        // Invalidate the previous timer to ensure we are querying on the most recent text input.
        self.autocompleteStatus.debounceTimer?.invalidate()
        
        // Perform query in 0.5 seconds
        self.autocompleteStatus.debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false){ _ in
            
            // Submit text input to AutoComplete API
            Radar.autocomplete(query: textInput, near: nil, limit: 4) { (status:RadarStatus, addresses:[RadarAddress]?) in

                guard status == .success, let addresses = addresses else {
                    return
                }
                
                // Update UI to present results.
                self.autocompleteStatus.autocompleteSuggestions = addresses
            }
        }
    }
    
    // MARK: In Store Mode
    // TODO: Implement 'In Store Mode"
    
    func checkForInStoreMode(){
        Radar.trackOnce { (status: RadarStatus, location: CLLocation?, events: [RadarEvent]?, user: RadarUser?) in
            guard status == .success, let events = events else{
                return
            }
            for event in events{
                if event.type == .userEnteredGeofence{
                    //Activate 'In Store' mode
                }else if event.type == .userExitedGeofence{
                    //Deactive 'In Store' mode if needed
                }
            }
        }
    }
    
    // MARK: App State Changes
    
    /// Identify if the user is in the store as app state changes.
    ///
    /// It is recommended to always call trackOnce on these state changes regardless if background tracking is enabled.
    public func appDidLaunch(){
        self.checkForInStoreMode()
    }
    public func appDidEnterForeground(){
        self.checkForInStoreMode()
    }
    
    // MARK: Primary Radar Events
    
    
    /// Triage and handoff specific Radar Event types to proper client side functions.
    ///
    ///
    /// The Radar event delegate can become bloated quickly as more functionality becomes dependant on location. We
    /// recommend triaging and passing out responsabilities to different functions.
     
    func didReceiveEvents(_ events: [RadarEvent], user: RadarUser?) {
        
        for radarEvent in events{
            switch radarEvent.type{
                
                case .userEnteredGeofence:
                    //Activate 'In Store' mode
                    break
                    
                case .userExitedGeofence:
                    //Deactivate 'In Store' mode
                    break
                    
                // Trip Events //
                case .userStartedTrip, .userUpdatedTrip:
                    self.tripTrackingStatus.expectedJourneyRemaining = Int(ceil(radarEvent.trip!.etaDuration))
                    
                case .userApproachingTripDestination:
                    self.tripTrackingStatus.tripStatus = .approaching
                    self.tripTrackingStatus.expectedJourneyRemaining = Int(ceil(radarEvent.trip!.etaDuration))
                    
                case .userArrivedAtTripDestination:
                    self.tripTrackingStatus.tripStatus = .arrived
                    self.tripTrackingStatus.expectedJourneyRemaining = 0
                    
                case .userStoppedTrip:
                    self.tripTrackingStatus.tripStatus = .completed
                    self.tripTrackingStatus.expectedJourneyRemaining = 0
                    
                default:
                    break
            }
        }
        
    }
    
    // MARK: Additional Radar Events
    
    func didUpdateClientLocation(_ location: CLLocation, stopped: Bool, source: RadarLocationSource) {
    }
    
    func didFail(status: RadarStatus) {
    }
    
    func didLog(message: String) {
    }
    
    func didUpdateLocation(_ location: CLLocation, user: RadarUser) {
    }
}

// MARK: Geofence Wrapper


/// Create a Hashable Radar Geofence for use in SwiftUI Elements (Loops & Maps)
///
///
/// Radar geofences are not identifiable/hashable by default. We can create this wrapper struct to permit geofences
/// being used 'directly' it views like Maps with this setup. This struct can be extended further to ensure all geofence
/// data (like geometry) is truly hashable.
 
struct IdentifiableGeofence: Identifiable {
    
    let isDummy: Bool
    
    let id: String //Internal Radar ID
    
    let externalId: String
    let tag: String
    let description: String
    
    let latitude: Double
    let longitude: Double
    
    let metadata: [AnyHashable: AnyHashable]
    
    var location: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(geofence: RadarGeofence) {
        self.isDummy = false
        self.id = geofence._id
        self.externalId = geofence.externalId!
        self.tag = geofence.tag!
        self.description = geofence.__description
        
        if geofence.geometry is RadarCircleGeometry{
            let geofence = geofence.geometry as! RadarCircleGeometry
            latitude = geofence.center.coordinate.latitude
            longitude = geofence.center.coordinate.longitude
        }else{
            let geofence = geofence.geometry as! RadarPolygonGeometry
            latitude = geofence.center.coordinate.latitude
            longitude = geofence.center.coordinate.longitude
        }
        
        guard let metadata = geofence.metadata else{
            self.metadata = [:]
            return
        }
        
        var t_metadata: [AnyHashable: AnyHashable] = [:]
        for (key, value) in metadata {
            if value is Bool{
                t_metadata[key] = value as! Bool
            }else if value is Double {
                t_metadata[key] = value as! Double
            }else{
                t_metadata[key] = value as! String
            }
        }
        self.metadata = t_metadata
        
    }
}

// MARK: Extensions

extension IdentifiableGeofence: Hashable {
    static func == (lhs: IdentifiableGeofence, rhs: IdentifiableGeofence) -> Bool {
        return lhs.id == rhs.id
    }
    
    //Dummy Geofence for simple Map Markers
    init(coordinate: CLLocationCoordinate2D){
        self.isDummy = true
        self.id = ""
        self.externalId = ""
        self.tag = ""
        self.description = ""
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.metadata = [:]
    }
}
