//
//  ContentView.swift
//  MapWWDC2023
//
//  Created by Steven Yung on 10/22/23.
//

import SwiftUI
import MapKit

extension CLLocationCoordinate2D {
    static let parking = CLLocationCoordinate2D(latitude: 42.354528, longitude: -71.068369)
    static let appleHQ = CLLocationCoordinate2D(latitude: 37.3359404078055, longitude: -122.0083711891967)
}

extension MKCoordinateRegion {
    static let boston = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 42.360256,
            longitude: -71.057279),
        span: MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1)
    )
    static let northShore = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: 42.547408,
            longitude: -70.870085),
        span: MKCoordinateSpan(
            latitudeDelta: 0.5,
            longitudeDelta: 0.5)
    )
}

struct ContentView: View {
    
    // sets map position
    @State private var position: MapCameraPosition = .automatic
    
    // keep track of current map region
    @State private var visibleRegion: MKCoordinateRegion?
    
    // results of search
    @State private var searchResults: [MKMapItem] = []
    
    // enables selection of search results
    @State private var selectedResult: MKMapItem?
    
    // routing info
    @State private var route: MKRoute?
    
    @State private var lookAroundScene: MKLookAroundScene?
    
    var body: some View {
        Map(position: $position, selection: $selectedResult) {
            // marker example
            //Marker("Parking", coordinate: .parking)
            
            // annotation example with zstack for graphic
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
            .annotationTitles(.hidden)  // hides the title "Parking"
            
            ForEach(searchResults, id:\.self) { result in
                Marker(item: result)
            }
            .annotationTitles(.hidden)
            
            if let route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        // other options
        //.mapStyle(.imagery(elevation: .realistic))
        // hybrid is imagery with roads and labels
        //.mapStyle(.hybrid(elevation: .realistic))

        // search buttons on bottom
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    if let selectedResult {
                        ItemInfoView(selectedResult: selectedResult, route: route)
                            .frame(height: 128)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.top)
                            .padding(.horizontal)
                    }
                    BeanTownButtons(
                        position: $position,
                        searchResults: $searchResults,
                        visibleRegion: visibleRegion
                    )
                    .padding(.top)
                }
                Spacer()
            }
            .background(.ultraThinMaterial)
        }
        .onChange(of: searchResults) {
            position = .automatic
        }
        .onChange(of: selectedResult) {
            getDirections()
        }
        .onMapCameraChange { context in
            visibleRegion = context.region
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
    ContentView()
}
