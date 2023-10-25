//
//  ItemInfoView.swift
//  MapWWDC2023
//
//  Created by Steven Yung on 10/23/23.
//

import SwiftUI
import MapKit

struct ItemInfoView: View {
    var selectedResult: MKMapItem
    //var route: MKRoute?
    
    @State private var lookAroundScene: MKLookAroundScene?
    
    /*private var travelTime: String? {
        guard let route else { return nil}
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }*/
    
    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("\(selectedResult.name ?? "")")
                    /*if let travelTime {
                        Text(travelTime)
                    }*/
                    
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
    
    func getLookAroundScene() {
        lookAroundScene = nil
        Task {
            let request = MKLookAroundSceneRequest(mapItem: selectedResult)
            lookAroundScene = try? await request.scene
        }
    }
}


#Preview {
    ItemInfoView(selectedResult: MKMapItem(placemark: .init(coordinate: .parking)))
}

