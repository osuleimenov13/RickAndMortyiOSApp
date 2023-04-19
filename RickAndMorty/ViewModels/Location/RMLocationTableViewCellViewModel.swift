//
//  RMLocationTableViewCellViewModel.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 17.04.2023.
//

import Foundation

struct RMLocationTableViewCellViewModel: Hashable {
    
    private let location: RMLocation
    
    init(location: RMLocation) {
        self.location = location
    }
    
    public var name: String {
        return location.name
    }

    public var type: String {
        return "Type: " + location.type
    }
    
    public var dimension: String {
        return location.dimension
    }
    
    static func == (lhs: RMLocationTableViewCellViewModel, rhs: RMLocationTableViewCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(location.id) // can hash only id
        hasher.combine(dimension)
        hasher.combine(type)
    }
}
