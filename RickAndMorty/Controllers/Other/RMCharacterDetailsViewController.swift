//
//  RMCharacterDetailsViewController.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 28.02.2023.
//

import UIKit

/// Controller to show info about single character
final class RMCharacterDetailsViewController: UIViewController {

    private let viewModel: RMCharacterDetailsViewViewModel
    
    init(viewModel: RMCharacterDetailsViewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = viewModel.title
    }

}
