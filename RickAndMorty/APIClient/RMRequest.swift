//
//  RMRequest.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 19.02.2023.
//

import Foundation

/// Object that represents a singlet API call
final class RMRequest {
    /// API Constants
    private struct Constants {
        static let baseUrl = "https://rickandmortyapi.com/api"
    }
    
    /// Desired endpoint
    private let endpoint: RMEndpoint
    
    /// Path components for API, if any
    private let pathComponents: Set<String>
    
    /// Query arguments for API, if any
    private let queryParameters: [URLQueryItem]

    /// Constructed url for the api reguest in string format
    private var urlString: String {
        var string = Constants.baseUrl
        string += "/"
        string += endpoint.rawValue
        
        if !pathComponents.isEmpty {
            pathComponents.forEach({ string += "/\($0)"})
        }
        
        if !queryParameters.isEmpty {
            string += "?"
            let argumentsString = queryParameters.compactMap {
                guard let value = $0.value else { return nil }
                return "\($0.name)=\(value)"
            }.joined(separator: "&")
            
            string += argumentsString
        }
        
        return string
    }
    
    
    /// Computed & constructed API url
    public var url: URL? {
        return URL(string: urlString)
    }
    
    // MARK: - Public
    
    /// Desired http method
    public let httpMethod = "GET"
    
    
    /// Initialize RMRequest
    /// - Parameters:
    ///   - endpoint: Target endpoint
    ///   - pathComponents: Collection of Path components
    ///   - queryParameters: Collection of query parameters
    public init(endpoint: RMEndpoint, pathComponents: Set<String> = [], queryParameters: [URLQueryItem] = []) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
        
}
