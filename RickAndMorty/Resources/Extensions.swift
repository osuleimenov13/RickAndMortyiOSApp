//
//  Extensions.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 23.02.2023.
//

import UIKit

extension UIView {
    
    func addSubviews(_ views: UIView...) {
        views.forEach({
            addSubview($0)
        })
    }
    
    
}
