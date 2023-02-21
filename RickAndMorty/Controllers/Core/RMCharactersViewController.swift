//
//  RMCharacterViewController.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 18.02.2023.
//

import UIKit

/// Controller to show and search for Characters
final class RMCharactersViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Characters"
        
        let request = RMRequest(
            endpoint: .character,
            queryParameters: [
                URLQueryItem(name: "name", value: "rick"),
                URLQueryItem (name: "status", value: "alive")
            ]
        )
        print (request.url)
    }
    

}
