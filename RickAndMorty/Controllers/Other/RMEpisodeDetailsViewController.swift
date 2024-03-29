//
//  RMEpisodeDetailsViewController.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 10.04.2023.
//

import UIKit

/// VC to show details about single episode
final class RMEpisodeDetailsViewController: UIViewController, RMEpisodeDetailsViewViewModelDelegate, RMEpisodeDetailsViewDelegate {
    

    private let viewModel: RMEpisodeDetailsViewViewModel
    
    private let detailsView = RMEpisodeDetailsView()
    
    // MARK: - Init
    
    init(url: URL?) {
        self.viewModel = RMEpisodeDetailsViewViewModel(endpointUrl: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Episode"
        view.addSubview(detailsView)
        setUpConstraints()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        
        viewModel.delegate = self // who gets notified as delegate once smth interesting happens and we make real implementation of delegate here as we rised hand and said I'm the delegate - ok but to be so you have to implement some functionality
        viewModel.fetchEpisodeData() // initailly we called this func from viewModel's init() but to avoid edge case when fetching happens faster than assigning viewModel's delegate (which is this VC)
        detailsView.delegate = self // delegate to open CharacterView from EpisodeDetailsView
    }
    
    @objc private func didTapShare() {
        
    }

    private func setUpConstraints() {
        NSLayoutConstraint.activate([
        detailsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        detailsView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
        detailsView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor) ,
        detailsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    // MARK: - ViewModel Delegate
        
    func didFetchEpisodeDetails() {
        detailsView.configure(with: viewModel) // once we get notified from ViewModel via delegate protocol that fetching of episodes done we set up our View UI
    }
    
    // MARK: - View Delegate
    
    func rmEpisodeDetailsView(_ episodeDetailsView: RMEpisodeDetailsView, didSelectCharacter character: RMCharacter) {
        let vc = RMCharacterDetailsViewController(viewModel: .init(character: character))
        vc.title = character.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
