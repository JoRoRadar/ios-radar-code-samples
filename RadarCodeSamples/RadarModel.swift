//
//  RadarModel.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 3/22/22.
//

import Foundation
import RadarSDK
import MapKit

class RadarModel: NSObject, RadarDelegate, ObservableObject {
    
    let permissionsModel = PermissionsModel()
    
    // Arrival Push Notification Properties
    
    @Published var region : MKCoordinateRegion = MKCoordinateRegion() //Need to initialize 
    @Published var nearbyGeofences : [RadarMapAnnotation] = []
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    //
    
    override init(){
        super.init()
        
        Radar.setDelegate(self)
        
        Radar.setUserId("SampleUser")
        Radar.setDescription("This is a Radar User created from the Radar Code Samples repo.")
        
        Radar.setMetadata(["CodeFeature" : ""])
        
        // Custom tracking options to help showcase this feature based on the included GPX file.
        let customTrackingOptions : RadarTrackingOptions = RadarTrackingOptions(from: RadarTrackingOptions.presetContinuous.dictionaryValue())
        customTrackingOptions.desiredStoppedUpdateInterval = 4
        customTrackingOptions.desiredMovingUpdateInterval = 4
        customTrackingOptions.desiredSyncInterval = 4
        
        //To respond to arrival we need to be tracking in both foreground and background.
        Radar.startTracking(trackingOptions: customTrackingOptions)
        
        self.setupMapData()
        
        //Request push notification permission for local notifications
        self.notificationCenter.requestAuthorization(options: [.alert]) { granted, error in
        }
    }
    
    // MARK: Arrival Notification Features
    
    /**
     Setup the map as a visual add for the 'Arrival Notification' feature.
     */
    func setupMapData(){
        Radar.trackOnce { (status: RadarStatus, location: CLLocation?, events: [RadarEvent]?, user: RadarUser?) in
            guard status == .success, let location = location else {
                return
            }
            
            //Center the map around the users location.
            let region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.region = region

            Radar.searchGeofences(near: location, radius: 1000, tags: ["<RadarGeofenceTags>"], metadata: nil, limit: 10) { (status: RadarStatus, location : CLLocation?, geofences: [RadarGeofence]? ) in
                guard status == .success, let geofences = geofences else {
                    return
                }

                //Place map annotations for each geofence.
                for geofence in geofences {
                    let circleGeometry : RadarCircleGeometry = geofence.geometry as! RadarCircleGeometry
                    self.nearbyGeofences.append(
                        RadarMapAnnotation(name: geofence.__description, coordinate: circleGeometry.center.coordinate )
                    )
                }
            }
        }
    }
    
    /**
     Helper function to send a local push notification for geofence arrival.
     */
    func sendLocalNotificationOnArrival(_ message:String){
        
        //Standard process for sending a basic local push notification.
        self.notificationCenter.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional,settings.alertSetting == .enabled else{
                return
            }
            
            let content = UNMutableNotificationContent()
            
            content.title = "Arrived at Geofence"
            content.body = message
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "1", content: content, trigger: trigger)
        
            self.notificationCenter.add(request, withCompletionHandler: nil)
        }
    }
    
    // MARK: App State Changes
    
    public func appDidEnterForeground(){
        print("App Entered Foreground")
    }
    
    // MARK: Primary Radar Events
    
    /**
     Leverage the Radar event callaback to send a push notification on arrival. Only interested in the first event for this sample.
     */
    func didReceiveEvents(_ events: [RadarEvent], user: RadarUser?) {
        guard !events.isEmpty, let geofence = events[0].geofence else {
            return
        }
        
        self.sendLocalNotificationOnArrival(geofence.__description)
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

// MARK: Custom Map Annotation

// Optional custom MapAnnotation
struct RadarMapAnnotation : Identifiable {
    let id  = UUID()
    let name : String
    var coordinate: CLLocationCoordinate2D
}
