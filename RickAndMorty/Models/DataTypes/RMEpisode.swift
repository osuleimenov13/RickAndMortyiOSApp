//
//  RMEpisode.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 18.02.2023.
//

import Foundation

struct RMEpisode: Codable {
    let id: Int
    let name: String
    let air_date: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
}
