//
//  MapKitTutorialSearch.swift
//  IS693R-Maps
//
//  Created by Cade Loar on 8/12/24.
//


// https://developer.apple.com/documentation/mapkit/mapkit_for_appkit_and_uikit/interacting_with_nearby_points_of_interest


import Foundation
import SwiftUI
import SwiftData
import MapKit


struct MapKitTutorialSearch: View {
    
    @Environment(ViewModel.self) private var viewModel
    // Change back to @Binding when auto complete search is ready
    @Binding var searchResults: [MKMapItem]
    @State var searchString: String = ""
    var visibleRegion: MKCoordinateRegion?
    @State private var displayTrip: Trip?
    @State var trips: [Trip] = []
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search for a destination", text: $searchString)
                    .onSubmit {
                        search(for: searchString)
                    }
            }
            .padding(12)
            .background(.gray.opacity(0.1))
            .cornerRadius(8)
            .foregroundColor(.primary)
            
            List {
                Section {
                    ForEach(viewModel.trips, id: \.self) { trip in
                        HStack {
                            Button(trip.title) {
                                displayTrip = trip
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                    }
                } header: {
                    Text("Trips")
                }
            }
            .contentMargins(1)
            .scrollIndicators(.hidden)
            .listStyle(.plain)
        }
        .padding()
        .interactiveDismissDisabled()
        .presentationDetents([.height(80), .medium, .fraction(0.999)])
        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.999)))
        .sheet(item: $displayTrip) { trip in
            VStack {
                List {
                    ForEach(trip.destinations) { dest in
                        Text(dest.name)
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationBackgroundInteraction(.enabled(upThrough: .large))
        }
//        .task{
//            print("Loading trips to display them on the search sheet...")
//            trips = viewModel.trips
//        }
        .environment(viewModel)
        
    }
    
    func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = [.address, .physicalFeature, .pointOfInterest]
        request.region = visibleRegion ?? MKCoordinateRegion(
            center: .parking,
            span: MKCoordinateSpan(latitudeDelta: 0.0125, longitudeDelta: 0.0125)
        )
        
        Task {
            let search = MKLocalSearch(request: request)
            let response = try? await search.start()
            searchResults = response?.mapItems ?? []
            print(searchResults.first ?? [])
        }
    }
}

//#Preview {
//    let container = { () -> ModelContainer in
//        do {
//            return try ModelContainer(
//                for: Destination.self,
//                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//            )
//        } catch {
//            fatalError("Failed to create ModelContainer for Items.")
//        }
//    }()
//    
//    let viewModel = ViewModel(container.mainContext)
//    
//    return MapKitTutorialSearch(searchResults: [MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.35549591, longitude: -71.06139420)))])
//        .modelContainer(container)
//        .environment(viewModel)
//}
