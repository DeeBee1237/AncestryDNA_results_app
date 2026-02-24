//
//  AncestryModel.swift
//  AncestryDNAViewPreviousResults
//
//  Created by Joseph on 24/02/2026.
//

import Foundation

struct AllYearsResponse: Decodable {
    var results: [Int]
}

class AncestryModel {
    
    public func getAllDNATestYears() async -> [Int] {
        
        guard let url = URL(string: "https://www.ancestry.com.au/dna/origins/secure/tests/\(Constants.testID)/ethnicity/versions") else {
            print("Invalid URL")
            return []
        }
        
        do {
            
            var urlRequest = URLRequest(url: url)
            
            urlRequest.httpMethod = "GET"
            urlRequest.setValue(Constants.ancestryCookie, forHTTPHeaderField: "Cookie")
            urlRequest.httpShouldHandleCookies = true
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            print(data)
            print(response)
            
            let allYears = try JSONDecoder().decode([Int].self, from: data)
            return allYears
            
        } catch {
            print("Invalid data")
            return []
        }


        
    }
    
}
