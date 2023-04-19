//
//  RMSettingsCellViewModel.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 16.04.2023.
//

import UIKit

struct RMSettingsCellViewModel: Identifiable { // cause we using SwiftUI and it wants our actual viewModels to be identifiable. SwiftUI will loop over a collection of these and disambiguate thanks to unique view models (id).
    
    let id = UUID()
    public let type: RMSettingsOption
    public let onTapHandler: (RMSettingsOption) -> Void
    
    // MARK: - Init
    
    init(type: RMSettingsOption, onTapHandler: @escaping (RMSettingsOption) -> Void) {
        self.type = type
        self.onTapHandler = onTapHandler
    }
    
    // MARK: - Public
    
    public var image: UIImage? {
        return type.iconImage
    }
    
    public var title: String {
        return type.displayTitle
    }
    
    public var iconContailnerColor: UIColor {
        return type.iconContainerColor
    }
}
