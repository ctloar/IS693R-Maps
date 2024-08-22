//
//  MapKitTutorialSearch.swift
//  IS693R-Maps
//
//  Created by Cade Loar on 8/12/24.
//


// https://developer.apple.com/documentation/mapkit/mapkit_for_appkit_and_uikit/interacting_with_nearby_points_of_interest


import Foundation
import SwiftUI
import MapKit


struct MapKitTutorialSearch: View {
    
    @Binding var searchResults: [MKMapItem]
    @State var searchString: String = ""
    var visibleRegion: MKCoordinateRegion?
    
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
            Spacer()
        }
        .padding()
        .interactiveDismissDisabled()
        .presentationDetents([.height(80), .medium, .large])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        
//        HStack{
//            TextField("Search", text: $searchString)
//            Button {
//                search(for: searchString)
//            } label: {
//                Label("Search", systemImage: "magnifyingglass")
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .labelStyle(.iconOnly)
    }
    
    func search(for query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
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
