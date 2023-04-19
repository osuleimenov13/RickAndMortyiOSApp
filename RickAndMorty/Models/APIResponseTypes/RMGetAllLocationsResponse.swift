//
//  RMGetAllLocationsResponse.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 17.04.2023.
//

import Foundation

struct RMGetAllLocationsResponse: Codable {
    struct Info: Codable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }

    let info: Info
    let results: [RMLocation]
}
