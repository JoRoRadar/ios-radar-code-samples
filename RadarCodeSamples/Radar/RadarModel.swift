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
    
    @Published var isOnTrip: Bool = false
    @Published var tripStatus: RadarTripStatus = .unknown
    @Published var expectedJourneyRemaining: Int?
    
    @Published var currentRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 30, longitude: -122), latitudinalMeters: 1000, longitudinalMeters: 1000)
    @Published var nearbyGeofences: [IdentifiableGeofence] = []
    
    @Published var autocompleteSuggestions: [RadarAddress] = []
    
    var debounceTimer : Timer? // A timer is leveraged to ensure we are throttling API requests.
    
    var radarAPIKeyType: String = Constants.Design.Primary.Text.rKeyTypeTextProd
    
    var permissionsModel = PermissionsModel()
    
    private var currentLocation: CLLocationCoordinate2D?
//    private var runningFeatureFlags: ActiveFeatures = ActiveFeatures()
    @Published var autocompleteStatus: AutocompleteStatus = AutocompleteStatus()
    @Published var geofenceSearchStatus: GeofenceSearchStatus = GeofenceSearchStatus()
    @Published var tripTrackingStatus: TripTrackingStatus = TripTrackingStatus()
    
    let defaultBackgroundTrackingOption = RadarTrackingOptions.presetContinuous
    let radarGeofenceSearchRadius:Int32 = Constants.Radar.Defaults.rDefaultSearchRadius
    let geofenceTag: String = Constants.Radar.Defaults.rGeofenceTag
    
    /// Status of all running async requests
    
    struct AutocompleteStatus {
        
    }
    
    struct GeofenceSearchStatus {
        var isRunningNearbySearch: Bool = false
    }
    
    struct TripTrackingStatus {
        
    }
    struct ActiveFeatures {
        var isRunningNearbySearch: Bool = false
    }
    
    override init(){
        super.init()
        
        Radar.setDelegate(self)
        
        Radar.setUserId(radarUserId)
        Radar.setDescription(Constants.Radar.Defaults.rUserDescription)
        
        Radar.setMetadata( Constants.Radar.Defaults.rUserMetadata)
        self.updateRegion()
    }
    
    // MARK: Radar Enabled Features
    
    func startTripForSelectedLocation(selectedGeofence:IdentifiableGeofence){
        
        if self.isOnTrip{
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
        
        self.tripStatus = .started
        self.isOnTrip = true
    }
    
    //Complete a trip and stop background tracking.
    func completeCurrentTrip(){
        Radar.completeTrip()
        Radar.stopTracking()
        self.tripStatus = .completed
        self.isOnTrip = false
    }
    
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
    
    /*
     Implementation of a 'Nearby Locations' feature
     */
    func findNearbyLocations(address:RadarAddress? = nil) {
        
        if runningFeatureFlags.isRunningNearbySearch {
            return
        }
        
        runningFeatureFlags.isRunningNearbySearch = true
        
        // A standard store locator will typically need only a radius and the geofence tag. As Radar allows for layering geofences on a location, we suggest a tag that represents the store footprint.
        if address != nil {
            let radarAddress = address!
            
            let location = CLLocation(latitude: radarAddress.coordinate.latitude, longitude: radarAddress.coordinate.longitude)
            self.currentRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            
            Radar.searchGeofences(near: location, radius: 10000, tags: [self.geofenceTag], metadata: nil, limit: 10){(status:RadarStatus, location: CLLocation?, geofences: [RadarGeofence]? ) in
                
                self.runningFeatureFlags.isRunningNearbySearch = false
                
                guard status == .success, let geofences = geofences else {
                    return
                }
                
                self.updateNearbyGeofences(geofences: geofences, additionalMarkers: [radarAddress.coordinate])
            }
        }else{
            Radar.searchGeofences(radius: radarGeofenceSearchRadius, tags: [self.geofenceTag], metadata: nil, limit: 10) { (status:RadarStatus, location: CLLocation?, geofences: [RadarGeofence]? ) in
                
                self.runningFeatureFlags.isRunningNearbySearch = false
                
                guard status == .success, let geofences = geofences else {
                    return
                }
                
                self.updateNearbyGeofences(geofences: geofences)
            }
        }
    }
    
    func updateNearbyGeofences(geofences: [RadarGeofence], additionalMarkers: [CLLocationCoordinate2D]? = nil){
        self.nearbyGeofences = []
        
        for geofence in geofences {
            self.nearbyGeofences.append(IdentifiableGeofence(geofence: geofence))
        }
        
        if additionalMarkers != nil {
            for marker in additionalMarkers! {
                self.nearbyGeofences.append(IdentifiableGeofence(coordinate: marker))
            }
        }
    }
    
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
    
    func generateAutocompleteSuggestions(textInput: String){
        // Invalidate the previous timer to ensure we are querying on the most recent text input.
        self.debounceTimer?.invalidate()
        
        // Perform query in 0.5 seconds
        self.debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false){ _ in
            
            // Submit text input to AutoComplete API
            Radar.autocomplete(query: textInput, near: nil, limit: 4) { (status:RadarStatus, addresses:[RadarAddress]?) in

                guard status == .success, let addresses = addresses else {
                    return
                }
                
                // Update UI to present results.
                self.autocompleteSuggestions = addresses
            }
        }
    }
    
    // MARK: App State Changes
    
    /*
     When the app enters the foreground or launches, call trackOnce to identify if a user is on store premise. The events can by filtered further by geofence.tag or geofence.metadata
     */
    public func appDidLaunch(){
        self.checkForInStoreMode()
    }
    public func appDidEnterForeground(){
        self.checkForInStoreMode()
    }
    
    // MARK: Primary Radar Events
    
    /*
     The Radar event delegate can become bloated quickly as more functionality becomes dependant on location.
     We recommend passing out responbalities to different modules rather than reacting to an event directly in the
     delegate function. This suggestion has not been implemented for the Sample Repo as it would have the reverse effect
     by creating bloat.
     */
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
                    self.expectedJourneyRemaining = Int(ceil(radarEvent.trip!.etaDuration))
                    
                case .userApproachingTripDestination:
                    self.tripStatus = .approaching
                    self.expectedJourneyRemaining = Int(ceil(radarEvent.trip!.etaDuration))
                    
                case .userArrivedAtTripDestination:
                    self.tripStatus = .arrived
                    self.expectedJourneyRemaining = 0
                    
                case .userStoppedTrip:
                    self.tripStatus = .completed
                    self.expectedJourneyRemaining = 0
                    
                default:
                    break
            }
        }
        
    }
    
    // MARK: Additional Radar Events
    
    func didUpdateClientLocation(_ location: CLLocation, stopped: Bool, source: RadarLocationSource) {
        //Keep track of a published location for any map view
        currentLocation = location.coordinate
    }
    
    func didFail(status: RadarStatus) {
    }
    
    func didLog(message: String) {
    }
    
    func didUpdateLocation(_ location: CLLocation, user: RadarUser) {
    }
}

// MARK: Geofence Wrapper

/*
 Radar geofences are not identifiable/hashable by default. We can create this wrapper
 struct to permit geofences being used 'directly' it views like Maps with this setup.
 
 This struct can be extended further to ensure all geofence data (like geometry) is truly hashable.
 */
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
    
    //Dummy Geofence for simple Map Markers
    init(coordinate: CLLocationCoordinate2D){
        self.isDummy = true
        self.id = "MapPlaceholder"
        self.externalId = "MapPlaceholder"
        self.tag = "MapPlaceholder"
        self.description = "MapPlaceholder"
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.metadata = [:]
    }
    
}

// MARK: Extensions

extension IdentifiableGeofence: Hashable {
    static func == (lhs: IdentifiableGeofence, rhs: IdentifiableGeofence) -> Bool {
        return lhs.id == rhs.id
    }
}
