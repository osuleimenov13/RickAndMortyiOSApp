//
//  RMCharacterStatus.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 21.02.2023.
//

import Foundation

enum RMCharacterStatus: String, Codable {
    case alive = "Alive"
    case dead = "Dead"
    case `unknown` = "unknown"
}
