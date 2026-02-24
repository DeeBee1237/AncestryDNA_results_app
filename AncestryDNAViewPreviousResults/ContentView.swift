//
//  ContentView.swift
//  AncestryDNAViewPreviousResults
//
//  Created by Joseph on 24/02/2026.
//

import SwiftUI

struct ContentView: View {
    
    private let model = AncestryModel()
    
    @State var allYearsLabel: String? = nil
    
    var body: some View {
        
        VStack {
            
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text(allYearsLabel ?? "Loading all years ...")
            
        }
        .padding()
        .task {
            
            let allYears = await model.getAllDNATestYears()
            
            allYearsLabel = allYears.description
            
        }
    }
}

#Preview {
    ContentView()
}
