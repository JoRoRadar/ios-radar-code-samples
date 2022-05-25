//
//  TrackingView.swift
//  RadarCodeSamples
//
//  Created by Joe Ross on 5/4/22.
//

import SwiftUI
import RadarSDK

enum RadarPreset {
    case EFFICIENT
    case RESPONSIVE
    case CONTINUOUS
    case CUSTOM
    
    var description : String {
        switch self {
        case .EFFICIENT: return "Efficient"
        case .RESPONSIVE: return "Responsive"
        case .CONTINUOUS: return "Continuous"
        case .CUSTOM: return "Custom"
        }
    }
}

struct TrackingSettingsView: View {
    
    @EnvironmentObject private var radarModel : RadarModel
    
    @State private var preset : RadarPreset = RadarPreset.RESPONSIVE
    @State private var desiredStoppedUpdateInterval : Int = 0
    @State private var desiredMovingUpdateInterval : Int = 150
    @State private var desiredSyncInterval : Int = 20
    @State private var desiredAccuracy : RadarTrackingOptionsDesiredAccuracy = .medium
    @State private var stopDuration : Int = 140
    @State private var stopDistance : Int = 70
    @State private var syncLocations : RadarTrackingOptionsSyncLocations = .all
    @State private var useStoppedGeofence : Bool = true
    @State private var stoppedGeofenceRadius : Int = 100
    @State private var useMovingGeofence : Bool = false
    @State private var movingGeofenceRadius : Int = 0
    @State private var syncGeofences : Bool = true
    @State private var useVisits : Bool = true
    @State private var useSignificantLocationChanges : Bool = true
    
    let saveButtonPadding:CGFloat = 10
    let toggleTrailingPadding:CGFloat = 10
    let updateIntervalMinValue:Int = 0
    let updateIntervalMovingStoppedMaxValue:Int = 200
    let updateIntervalSyncMaxValue:Int = 60
    
    let stopDurationMin:Int = 0
    let stopDurationMax:Int = 180
    
    let stopDistanceMin:Int = 0
    let stopDistanceMax:Int = 100
    
    let stoppedGeofenceRadiusMin:Int = 0
    let stoppedGeofenceRadiuMax:Int = 400
    
    let movingGeofenceRadiusMin:Int = 0
    let movingGeofenceRadiusMax:Int = 400
    
    var body: some View {
            VStack{
                Divider()
                    .navigationBarTitle(Constants.Design.TrackSettings.Text.sNavigationTitle, displayMode: .inline)
                    .onAppear(perform: {
                        adoptRadarTrackingOptions(options: radarModel.customTrackingOptions)
                    })
                Group{
                    Text(Constants.Design.TrackSettings.Text.sViewDescription)
                        .fontWeight(.light)
                    Button(action: {
                        radarModel.customTrackingOptions = compileRadarTrackingOptions()
                    }) {
                        Text(Constants.Design.TrackSettings.Text.bSaveText)
                            .padding(saveButtonPadding)
                    }
                    .frame(width:Constants.screenWidth)
                    .background(Color.primaryColor)
                    .foregroundColor(Color.white)
                    Divider()
                }
                ScrollView(showsIndicators: false){
                    VStack{
                        /*
                         Need to use weird Grouping since SwiftUI Views only support 10 invidual views per stack.
                         */
                        Group{
                            
                            Picker(Constants.Design.TrackSettings.Text.pRadarPresetsTitle, selection: $preset) {
                                Text(RadarPreset.EFFICIENT.description).tag(RadarPreset.EFFICIENT)
                                Text(RadarPreset.RESPONSIVE.description).tag(RadarPreset.RESPONSIVE)
                                Text(RadarPreset.CONTINUOUS.description).tag(RadarPreset.CONTINUOUS)
                                Text(RadarPreset.CUSTOM.description).tag(RadarPreset.CUSTOM)
                            }
                            .pickerStyle(.segmented)
                            .background(Color.backgroundShaderColor)
                            .onChange(of: preset) { presetOption in updateValuesForPreset(presetOption: presetOption) }
            
                            OptionSlider(sliderText: Constants.Design.TrackSettings.Text.updateOptionSliderStopped, radarPreset: $preset, sliderValue: $desiredStoppedUpdateInterval, minValue: updateIntervalMinValue, maxValue: updateIntervalMovingStoppedMaxValue)
                            OptionSlider(sliderText: Constants.Design.TrackSettings.Text.updateOptionSliderMoving, radarPreset: $preset, sliderValue: $desiredMovingUpdateInterval, minValue: updateIntervalMinValue, maxValue: updateIntervalMovingStoppedMaxValue)
                            OptionSlider(sliderText: Constants.Design.TrackSettings.Text.updateOptionSliderSync, radarPreset: $preset, sliderValue: $desiredSyncInterval, minValue: updateIntervalMinValue, maxValue: updateIntervalSyncMaxValue)
                        
                            Picker(Constants.Design.TrackSettings.Text.desiredAccuracyTitle, selection: $desiredAccuracy){
                                Text("Low").tag(RadarTrackingOptionsDesiredAccuracy.low)
                                Text("Medium").tag(RadarTrackingOptionsDesiredAccuracy.medium)
                                Text("High").tag(RadarTrackingOptionsDesiredAccuracy.high)
                            }
                            .pickerStyle(.segmented)
                            .background(Color.backgroundShaderColor)
                            .onChange(of: desiredAccuracy ) { _ in
                                if !desiredAccuracyMatchesPreset(){ preset = .CUSTOM }
                            }
                        }
                        Group{
                            OptionSlider(sliderText: "Stop Duration", radarPreset: $preset, sliderValue: $stopDuration, minValue: stopDurationMin, maxValue: stopDurationMax)
                            OptionSlider(sliderText: "Stop Distance", radarPreset: $preset, sliderValue: $stopDistance, minValue: stopDistanceMin, maxValue: stopDistanceMax)
                            
                            Picker(Constants.Design.TrackSettings.Text.syncLocationTypesTitle, selection: $syncLocations){
                                Text("All").tag(RadarTrackingOptionsSyncLocations.all)
                                Text("Stops & Exits").tag(RadarTrackingOptionsSyncLocations.stopsAndExits)
                                Text("None").tag(RadarTrackingOptionsSyncLocations.none)
                            }
                            .pickerStyle(.segmented)
                            .background(Color.backgroundShaderColor)
                            .onChange(of: syncLocations ) { syncType in
                                if syncType != RadarTrackingOptionsSyncLocations.all { preset = .CUSTOM }
                            }

                            Toggle(Constants.Design.TrackSettings.Text.useStoppedGeofencesTitle, isOn: $useStoppedGeofence)
                                .padding(.trailing, toggleTrailingPadding)
                            OptionSlider(sliderText: Constants.Design.TrackSettings.Text.stoppedGeofenceRadiusSliderTitle, radarPreset: $preset, sliderValue: $stoppedGeofenceRadius, minValue: stoppedGeofenceRadiusMin, maxValue: stoppedGeofenceRadiuMax)

                            Toggle(Constants.Design.TrackSettings.Text.useMovingGeofencesTitle, isOn: $useMovingGeofence)
                                .padding(.trailing, toggleTrailingPadding)
                            OptionSlider(sliderText: Constants.Design.TrackSettings.Text.movingGeofenceRadiusSliderTitle, radarPreset: $preset, sliderValue: $movingGeofenceRadius, minValue: movingGeofenceRadiusMin, maxValue: movingGeofenceRadiusMax)

                            Toggle(Constants.Design.TrackSettings.Text.syncGeofencesTitle, isOn: $syncGeofences)
                                .padding(.trailing, toggleTrailingPadding)
                            Toggle(Constants.Design.TrackSettings.Text.useSignificantLocationsTitle, isOn: $useSignificantLocationChanges)
                                .padding(.trailing, toggleTrailingPadding)
                        }
                    }
                }
                Spacer()
            }
    }
    
}

struct OptionSlider: View {
    
    var sliderText : String
    
    @State private var isEditing : Bool = false
    
    @Binding var radarPreset : RadarPreset
    
    @Binding var sliderValue : Int
    var sliderValueProxy: Binding<Double>{
        Binding<Double>(get: {
            return Double(sliderValue)
        }, set: {
            sliderValue = Int($0)
        })
    }
    
    var minValue : Int
    var maxValue : Int
    
    
    var body: some View {
        HStack{
            Text(sliderText)
            Slider(
                value: sliderValueProxy,
                in: Double(minValue)...Double(maxValue),
                step: 1.0,
                onEditingChanged: { editing in
                    isEditing = editing
                    radarPreset = .CUSTOM
                }
            )
            Text(sliderValue.description)
                .foregroundColor(isEditing ? Color.primaryColor : Color.backgroundShaderColor)
        }
    }
}

struct TrackingSettingsView_Previews: PreviewProvider {
    static let radarModel : RadarModel = RadarModel()
    
    static var previews: some View {
        TrackingSettingsView()
            .environmentObject(radarModel)
    }
}


extension TrackingSettingsView{
    
    /*
     This wouldn't likey be included in a consumer facing app
     but for this project it has been included for testing.
     
     You could map these but we don't want to copy all options.
     For now we will manually set the fields we are interested in.
     */
    func adoptRadarTrackingOptions(options:RadarTrackingOptions?) {
        guard let options = options else {
            return
        }

        desiredStoppedUpdateInterval = Int(options.desiredStoppedUpdateInterval)
        desiredMovingUpdateInterval = Int(options.desiredMovingUpdateInterval)
        desiredSyncInterval = Int(options.desiredSyncInterval)
        desiredAccuracy = options.desiredAccuracy
        stopDuration = Int(options.stopDuration)
        stopDistance = Int(options.stopDistance)
        syncLocations = options.syncLocations
        useStoppedGeofence = options.useStoppedGeofence
        stoppedGeofenceRadius = Int(options.stoppedGeofenceRadius)
        useMovingGeofence = options.useMovingGeofence
        movingGeofenceRadius = Int(options.movingGeofenceRadius)
        syncGeofences = options.syncGeofences
        useVisits = options.useVisits
        useSignificantLocationChanges = options.useSignificantLocationChanges
    }
    func compileRadarTrackingOptions() -> RadarTrackingOptions {
        
        let options = RadarTrackingOptions()
        options.desiredStoppedUpdateInterval = Int32(desiredStoppedUpdateInterval)
        options.desiredMovingUpdateInterval = Int32(desiredMovingUpdateInterval)
        options.desiredSyncInterval = Int32(desiredSyncInterval)
        options.desiredAccuracy = desiredAccuracy
        options.stopDuration = Int32(stopDuration)
        options.stopDistance = Int32(stopDistance)
        options.syncLocations = syncLocations
        options.useStoppedGeofence = useStoppedGeofence
        options.stoppedGeofenceRadius = Int32(stoppedGeofenceRadius)
        options.useMovingGeofence = useMovingGeofence
        options.movingGeofenceRadius = Int32(movingGeofenceRadius)
        options.syncGeofences = syncGeofences
        options.useVisits = useVisits
        options.useSignificantLocationChanges = useSignificantLocationChanges
        
        return options
    }
    
    func desiredAccuracyMatchesPreset() -> Bool {
        if preset == .RESPONSIVE && desiredAccuracy == .medium {
            return true
        }else if preset == .CONTINUOUS && desiredAccuracy == .high {
            return true
        }else if preset == .EFFICIENT && desiredAccuracy == .medium {
            return true
        }else{
            return false
        }
    }
    
    func updateValuesForPreset( presetOption: RadarPreset ){
        if presetOption == .RESPONSIVE {
            desiredStoppedUpdateInterval = 0
            desiredMovingUpdateInterval = 150
            desiredSyncInterval = 20
            desiredAccuracy = .medium
            stopDuration = 140
            stopDistance = 70
            syncLocations = .all
            useStoppedGeofence = true
            stoppedGeofenceRadius = 100
            useMovingGeofence = false
            movingGeofenceRadius = 0
            syncGeofences = true
            useVisits = true
            useSignificantLocationChanges = true
        }else if presetOption == .EFFICIENT {
            desiredStoppedUpdateInterval = 0
            desiredMovingUpdateInterval = 0
            desiredSyncInterval = 0
            desiredAccuracy = .medium
            stopDuration = 0
            stopDistance = 0
            syncLocations = .all
            useStoppedGeofence = false
            stoppedGeofenceRadius = 0
            useMovingGeofence = false
            movingGeofenceRadius = 0
            syncGeofences = true
            useVisits = true
            useSignificantLocationChanges = false
        }else if presetOption == .CONTINUOUS {
            desiredStoppedUpdateInterval = 30
            desiredMovingUpdateInterval = 30
            desiredSyncInterval = 20
            desiredAccuracy = .high
            stopDuration = 140
            stopDistance = 70
            syncLocations = .all
            useStoppedGeofence = false
            stoppedGeofenceRadius = 0
            useMovingGeofence = false
            movingGeofenceRadius = 0
            syncGeofences = false
            useVisits = false
            useSignificantLocationChanges = false
        }
    }
}
