//
//  RMCharacterDetailsViewViewModel.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 28.02.2023.
//

import Foundation

final class RMCharacterDetailsViewViewModel {
    
    private let character: RMCharacter
    
    init(character: RMCharacter) {
        self.character = character
    }
    
    public var title: String {
        character.name.uppercased()
    }
}
