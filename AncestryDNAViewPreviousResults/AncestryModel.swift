//
//  AncestryModel.swift
//  AncestryDNAViewPreviousResults
//
//  Created by Joseph on 24/02/2026.
//

import Foundation
// https://stackoverflow.com/questions/79779756/xcode-26-0-1-type-datacontroller-does-not-conform-to-protocol-observableobjec
import Combine
import SwiftUI

struct EthnicityResultsResponse: Decodable {
    var regions: [Region]
}

struct Region: Decodable {
    var key: String
    var percentage: Int
    var lowerConfidence: Int
    var upperConfidence: Int
    var lightColor: String
    var darkColor: String
}

struct RegionResultsDisplayObject: Hashable {
    let key: String
    let regionName: String
    let percentageDisplay: String
    let lightColor: Color?
    let darkColor: Color?
}

class AncestryModel : ObservableObject {
    
    @Published var resultsForYear: [RegionResultsDisplayObject] = []
    
    private func generateURLRequest(for urlString: String, httpMethod: String = "GET") -> URLRequest? {
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = httpMethod
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
        guard year > 0 else { return }
        guard let urlRequest = generateURLRequest(for: "https://www.ancestry.com.au/dna/origins/secure/tests/\(Constants.testID)/v2/ethnicity?version=\(year)") else {
            print("Invalid URL Request")
            return
        }
        
        do {
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            let allYears = try JSONDecoder().decode(EthnicityResultsResponse.self, from: data)
            
            //
            
            var displayObjects: [RegionResultsDisplayObject] = []
            
            for yearResult in allYears.regions {
                if let name = await getEthnicityNameForKey(key: yearResult.key, year: year) {
                    displayObjects.append(RegionResultsDisplayObject(key: yearResult.key, regionName: name, percentageDisplay: "\(yearResult.percentage)% ( \(yearResult.lowerConfidence)% - \(yearResult.upperConfidence)%)", lightColor: Color(hex: yearResult.lightColor), darkColor: Color(hex: yearResult.darkColor)))
                }
            }
            //
            
            
            self.resultsForYear = displayObjects
            
        } catch {
            print("Invalid data")
//            return nil
        }

    }
    
    public func getEthnicityNameForKey(key: String, year: Int) async -> String? {
        
        guard var urlRequest = generateURLRequest(for:"https://www.ancestry.com.au/dna/origins/public/ethnicity/\(year)/names?locale=en-AU",httpMethod: "POST") else {
            print("Invalid URL Request")
            return nil
        }
        
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                
        do {
            // TODO: this catch block will not diferentiate between error thrown by this and an error thrown by the one below it
            let encoder = JSONEncoder()
            let test: [String] = [key]
            let postData = try encoder.encode(test)
            urlRequest.httpBody = postData
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            let mappings = try JSONDecoder().decode([String: String].self, from: data)
            
            return mappings.first?.value
        } catch {
            print("Invalid data")
            return nil
        }

    }
    
}
