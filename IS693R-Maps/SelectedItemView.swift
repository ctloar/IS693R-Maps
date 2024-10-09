//
//  SelectedItemView.swift
//  IS693R-Maps
//
//  Created by Cade Loar on 8/13/24.
//

import SwiftUI
import SwiftData
import MapKit

struct SelectedItemView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var lookAroundScene: MKLookAroundScene?
    var selectedResult: MKMapItem
    var route: MKRoute?
    
    
    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }
    
    func getLookAroundScene(){
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: selectedResult)
            lookAroundScene = try? await request.scene
        }
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    if let poiCategory = selectedResult.pointOfInterestCategory?.rawValue {
                        Text("\(poiCategory)")
                    }
                    HStack {
                        if let url = selectedResult.url {
                            Link(destination: url) {
                                Image(systemName: "safari")
                                    .foregroundColor(.black)
                                    .background{
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 60, height: 40)
                                    }
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        Button {
                            print("Calling \(selectedResult.phoneNumber ?? "no phone number")")
                        } label: {
                            Image(systemName: "phone")
                                .foregroundColor(.black)
                                .background{
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(.ultraThinMaterial)
                                        .frame(width: 60, height: 40)
                                }
                                .padding(.horizontal, 20)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    Text(selectedResult.phoneNumber ?? "No phone number")
                    
                }
                
                LookAroundPreview(initialScene: lookAroundScene)
                    .frame(height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing)
                    .overlay(alignment: .bottomTrailing) {
                        HStack {
                            Text("\(selectedResult.name ?? "")")
                            if let travelTime {
                                Text(travelTime)
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(10)
                    }
                    .onAppear {
                        getLookAroundScene()
                    }
                    .onChange(of: selectedResult) {
                        getLookAroundScene()
                    }
                
                
            }
            .toolbar {
                // ADD BUTTONS FOR WISH LIST AND PLANNED(?)
                ToolbarItem(placement: .topBarLeading) {
                    Text(selectedResult.name ?? "Unknown Location")
                        .font(.title)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        print("Marked as visited...")
                        let destination = Destination(
                            dateVisited: Date.now,
                            name: selectedResult.name ?? "Unknown Location",
                            address: selectedResult.placemark.thoroughfare ?? "Unknown Address",
                            city: selectedResult.placemark.locality ?? "Unknown City",
                            country: selectedResult.placemark.country ?? "Unknown Country",
                            identifier: selectedResult.identifier?.rawValue ?? "unknown",
                            trips: []
                        )
                        viewModel.addDestination(destination)
                        viewModel.destinations.forEach { dest in
                            print(dest.name)
                        }
                        
                    } label: {
                        Image(systemName: "plus.circle")
//                            .foregroundStyle(.black)
                    }
                }
                ToolbarItem {
                    Button {
                        let destination = Destination(
                            dateVisited: Date.now,
                            name: selectedResult.name ?? "Unknown Location",
                            address: selectedResult.placemark.thoroughfare ?? "Unknown Address",
                            city: selectedResult.placemark.locality ?? "Unknown City",
                            country: selectedResult.placemark.country ?? "Unknown Country",
                            identifier: selectedResult.identifier?.rawValue ?? "unknown",
                            trips: [favorites]
                        )
                        // add destination to trip
                        print("saved to favorites!")
                    } label: {
                        Image(systemName: "heart")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding([.leading, .vertical])
        }
        .interactiveDismissDisabled()
        .presentationDetents([.height(80), .medium, .large])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
        .environment(viewModel)
        
    }
}

//#Preview {
//    SelectedItemView(selectedResult: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.35549591, longitude: -71.06139420))))
//}

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
    
    let viewModel = ViewModel(container.mainContext)
    
    return SelectedItemView(selectedResult: MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.35549591, longitude: -71.06139420))))
        .modelContainer(container)
        .environment(viewModel)
}
