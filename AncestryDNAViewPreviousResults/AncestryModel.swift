//
//  AncestryModel.swift
//  AncestryDNAViewPreviousResults
//
//  Created by Joseph on 24/02/2026.
//

import Foundation
// https://stackoverflow.com/questions/79779756/xcode-26-0-1-type-datacontroller-does-not-conform-to-protocol-observableobjec
import Combine

struct EthnicityResultsResponse: Decodable {
    var regions: [Region]
}

struct Region: Decodable, Hashable {
    var key: String
    var percentage: Int
    var lowerConfidence: Int
    var upperConfidence: Int
}

class AncestryModel : ObservableObject {
    
    @Published var resultsForYear: [Region] = []
    
    private func generateURLRequest(for urlString: String) -> URLRequest? {
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = "GET"
        urlRequest.setValue(Constants.ancestryCookie, forHTTPHeaderField: "Cookie")
        urlRequest.httpShouldHandleCookies = true
        return urlRequest
    }
    
    public func getAllDNATestYears() async -> [Int] {
        
        guard let urlRequest = generateURLRequest(for: "https://www.ancestry.com.au/dna/origins/secure/tests/\(Constants.testID)/ethnicity/versions") else {
            print("Invalid URL Request")
            return []
        }
        
        do {
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            let allYears = try JSONDecoder().decode([Int].self, from: data)
            return allYears
            
        } catch {
            print("Invalid data")
            return []
        }
        
    }
    
    
    public func getResultsForYear(year: Int) async /*-> [Region]?*/ {
        
        guard let urlRequest = generateURLRequest(for: "https://www.ancestry.com.au/dna/origins/secure/tests/\(Constants.testID)/v2/ethnicity?version=\(year)") else {
            print("Invalid URL Request")
            return
        }
        
        do {
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            let allYears = try JSONDecoder().decode(EthnicityResultsResponse.self, from: data)
            self.resultsForYear = allYears.regions
            
        } catch {
            print("Invalid data")
//            return nil
        }

    }
    
}
