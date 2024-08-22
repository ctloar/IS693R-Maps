//
//  MapKitTutorialView.swift
//  IS693R-Maps
//
//  Created by Cade Loar on 8/12/24.
//


// https://developer.apple.com/documentation/mapkit/mapkit_for_appkit_and_uikit/interacting_with_nearby_points_of_interest

import Foundation
import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369)
}

struct MapKitTutorialView: View {
    
    @State private var showSearchSheet: Bool = true
    @State private var showDetailsSheet: Bool = false
    @State private var position: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?
    @State private var selectedFeature: MapFeature?
    @State private var route: MKRoute?
    
    var body: some View {
        
        Map(position: $position, selection: $selectedResult) {
            Annotation("Parking", coordinate: .parking) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(.background)
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.secondary, lineWidth: 5)
                    Image(systemName: "car")
                        .padding(5)
                }
            }
            .annotationTitles(.hidden)
            
            ForEach(searchResults, id: \.self) { result in
                Marker(item: result)
            }
//            .annotationTitles(.hidden)
            
            UserAnnotation()
            
            //            if let route {
            //                MapPolyline(route)
            //                    .stroke(.blue, lineWidth: 5)
            //            }
        }
        .mapStyle(.standard(elevation: .realistic))
        // This sheet is for search bar and search results
        // https://www.hackingwithswift.com/quick-start/swiftui/how-to-present-multiple-sheets#:~:text=If%20you%20want%20to%20show,to%20the%20same%20parent%20view.&text=Using%20this%20approach%2C%20both%20sheets%20will%20be%20displayed%20correctly.
        .sheet(isPresented: $showSearchSheet) {
            VStack {
                MapKitTutorialSearch(searchResults: $searchResults, visibleRegion: visibleRegion)
                if let selectedResult {
                    SelectedItemView(selectedResult: selectedResult, route: route)
//                        
                }
            }
            .sheet(isPresented: $showDetailsSheet) {
                if let selectedResult {
                    SelectedItemView(selectedResult: selectedResult, route: route)
                }
            }
        }
        
        // This sheet is for displaying information of a selected point of interest
        // Can't find any evidence that this is customizable
        // .mapItemDetailSheet(item: $selectedResult)
        
        
//        .onChange(of: selectedFeature) { previous, current in
//            print("Current \(current)")
//            guard let feature = current else { return }
//            print(feature)
//            let selectedMKItem = MKMapItem(placemark: MKPlacemark(coordinate: feature.coordinate))
////            showSheet = false
//            print("Name: \(selectedMKItem.name ?? "No name")")
//        }
        
        .onChange(of: searchResults) {
            position = .automatic
        }
        .onChange(of: selectedResult) {
            //            getDirections()
            if let selectedResult {
                print(selectedResult)
                showDetailsSheet = true
            } else {
                showDetailsSheet = false
            }
//            showSearchSheet=false
            
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        
    }
    
    func getDirections() {
        route = nil
        guard let selectedResult else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: .parking))
        request.destination = selectedResult
        
        Task {
            let directions = MKDirections(request: request)
            let response = try? await directions.calculate()
            route = response?.routes.first
        }
    }
}

#Preview {
    MapKitTutorialView()
}
