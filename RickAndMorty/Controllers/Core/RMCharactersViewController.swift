//
//  RMCharacterViewController.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 18.02.2023.
//

import UIKit

/// Controller to show and search for Characters
final class RMCharactersViewController: UIViewController {

    private let characterListView = RMCharacterListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Characters"
        view.addSubview(characterListView)
        
        setUpView()
    }
    
    private func setUpView() {
        NSLayoutConstraint.activate([
            characterListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            characterListView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            characterListView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            characterListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
