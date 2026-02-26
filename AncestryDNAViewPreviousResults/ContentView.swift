//
//  ContentView.swift
//  AncestryDNAViewPreviousResults
//
//  Created by Joseph on 24/02/2026.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var model = AncestryModel()
    
    @State var allYearsLabel: String? = nil
    
    @State private var selectedYear : Int = 0
    @State private var allYears : [Int]? = nil
    
    var body: some View {
        
        VStack {
            
            if (allYears == nil) {
                Text("Loading all available years ...")
            } else {
                
                VStack {
                    Picker("Select a year", selection: $selectedYear) {
                        ForEach(allYears!, id: \.self) {
                            Text($0.description).task {
                                await model.getResultsForYear(year: selectedYear)
                            }
                        }
                    }
                    .pickerStyle(.menu)
                    
                        ForEach(model.resultsForYear, id: \.key) { region  in
                            VStack {
                                Text(region.regionName)
                                Text(region.percentageDisplay)
                            }.padding(20)
                        }
                }
                
            }
        }
        .padding()
        .task {
            allYears = await model.getAllDNATestYears()
        }
    }
}

#Preview {
    ContentView()
}
