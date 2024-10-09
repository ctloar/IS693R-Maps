//
//  MapKitTutorialView.swift
//  IS693R-Maps
//
//  Created by Cade Loar on 8/12/24.
//

// MVP: Map by default displays all the locations you've been. Each is tappable with trip information.
// You can add a new destination by searching for it, selecting the appropriate result, and clicking an add button.
// Potential add on: Have 2 objects - trips and destinations - trips have numerous destinations, and you can filter your search by trip

// https://developer.apple.com/documentation/mapkit/mapkit_for_appkit_and_uikit/interacting_with_nearby_points_of_interest

import Foundation
import SwiftUI
import SwiftData
import MapKit

extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369)
}

struct MapKitTutorialView: View {
    
    @State private var viewModel: ViewModel
    
    @State private var showSearchSheet: Bool = true
    @State private var showDetailsSheet: Bool = false
    
    @State private var position: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedResult: MKMapItem?
    @State private var mapSelection: MapSelection<Int>?
    @State private var route: MKRoute?
    
    
    init(_ modelContext: ModelContext) {
            // Remember that _viewModel is the variable created by the @State
            // property wrapper.
            _viewModel = State(initialValue: ViewModel(modelContext))
    }
    
    var body: some View {
        
        Map(position: $position, selection: $mapSelection) {
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
            
//            if searchResults.isEmpty {
//                ForEach(viewModel.destinations) { destination in
//                    Marker(item: MKMapItem(
//                        placemark: MKPlacemark(
//                                coordinate: CLLocationCoordinate2D(
//                                    latitude: destination.latitude,
//                                    longitude: destination.longitude))))
//                }
//            } else {
            ForEach(searchResults.indices) { index in
                Marker(item: searchResults[index])
                        .tag(MapSelection(index))
            }
//            }
            
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
              
        .onChange(of: mapSelection) { previous, current in

            // if feature && value == nil, detailSHeet is false
            // else if feature !== nil, perform feature conversion to item
            // else if value !== nil, retrieve item from search results
            
            if ((current?.feature) != nil || (current?.value) != nil) {
                showDetailsSheet = true
            } else {
                showDetailsSheet = false
                return
            }
            
            if let index = mapSelection?.value {
                print("Search result: \(searchResults[index])")
                selectedResult = searchResults[index]
            }
            
            if let feature = mapSelection?.feature {
                print("Map feature: \(feature)")
                Task {
                    let request =  MKMapItemRequest(feature: feature)
                    
                    request.getMapItem { mapItem, error in
                        if let error = error {
                            print("Error fetching MKMapItem: \(error.localizedDescription)")
                            return
                        }
                        if let mapItem {
                            selectedResult = mapItem
                            print(mapItem)
    //                        showDetailsSheet = true
                        } else {
                          print("No map item found.")
                        }
                    }
                }
            }
           
        }
        
        .onChange(of: searchResults) {
            position = .automatic
            print(searchResults)
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .environment(viewModel)
        
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
    let container = { () -> ModelContainer in
        do {
            return try ModelContainer(
                for: Destination.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            fatalError("Failed to create ModelContainer for Items.")
        }
    }()
    
    return MapKitTutorialView(container.mainContext)
        .modelContainer(container)
}
