//
//  RMEpisodeDetailsViewController.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 10.04.2023.
//

import UIKit

/// VC to show details about single episode
final class RMEpisodeDetailsViewController: UIViewController {

    private let url: URL?
    
    // MARK: - Init
    
    init(url: URL?) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Episode"
        view.backgroundColor = .systemGreen
    }

}
