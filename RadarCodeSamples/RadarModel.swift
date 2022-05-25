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
    
    @Published var currentRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 30, longitude: -122), latitudinalMeters: 100, longitudinalMeters: 100)
    @Published var nearbyGeofences: [IdentifiableGeofence] = []
    
    var radarAPIKeyType: String = Constants.Design.Primary.Text.rKeyTypeTextProd
    
    var customTrackingOptions: RadarTrackingOptions? = nil
    
    var permissionsModel = PermissionsModel()
    
    private var currentLocation: CLLocationCoordinate2D?
    private var runningFeatureFlags: ActiveFeatures = ActiveFeatures()
    
    let defaultBackgroundTrackingOption = RadarTrackingOptions.presetContinuous
    let radarGeofenceSearchRadius:Int32 = 10000
    
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
        self.startTracking()
        
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
    func findNearbyLocations(appType: AppType) {
        //As the sample repo provides a launch screen and settings screen we filter out those options here.
        if appType == .None || appType == .Settings || runningFeatureFlags.isRunningNearbySearch {
            return
        }
        
        let tag = appType.description
        runningFeatureFlags.isRunningNearbySearch = true
        
        // A standard store locator will typically need only a radius and the geofence tag. As Radar allows for layering geofences on a location, we suggest a tag that represents the store footprint.
        Radar.searchGeofences(radius: radarGeofenceSearchRadius, tags: [tag], metadata: nil, limit: 10) { (status:RadarStatus, location: CLLocation?, geofences: [RadarGeofence]? ) in
            
            self.runningFeatureFlags.isRunningNearbySearch = false
            
            guard status == .success, let geofences = geofences else {
                return
            }
            
            self.nearbyGeofences = []
            for geofence in geofences {
                self.nearbyGeofences.append(IdentifiableGeofence(geofence: geofence))
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

extension RadarModel{
    /*
     To extend this sample repo for testing purposes the ability
     to alter tracking options was added. This functionality would
     not typically be available for a consumer and Radar.startTracking
     could be called directly with a predefined RadarTrackingOption.
     */    
    func startTracking(){
        guard let trackedOptions = customTrackingOptions else {
            Radar.startTracking(trackingOptions: defaultBackgroundTrackingOption)
            return
        }

        Radar.startTracking(trackingOptions: trackedOptions)
    }
}

// MARK: Geofence Wrapper

/*
 Radar geofences are not identifiable/hashable by default. We can create this wrapper
 struct to permit geofences being used 'directly' it views like Maps with this setup.
 
 This struct can be extended further to ensure all geofence data (like geometry) is truly hashable.
 */
struct IdentifiableGeofence: Identifiable {
        
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
}

extension RadarTrackingOptions{
    
    var stringValue : String {
        get {
            switch self{
            case RadarTrackingOptions.presetContinuous:
                return "Continuous (BG)"
            case RadarTrackingOptions.presetEfficient:
                return "Efficient (BG)"
            default:
                return "Responsive (BG)"
            }
        }
    }
}
