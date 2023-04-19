//
//  RMLocationDetailsViewController.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 18.04.2023.
//

import UIKit

/// VC to show details about single location
final class RMLocationDetailsViewController: UIViewController, RMLocationDetailsViewViewModelDelegate, RMLocationDetailsViewDelegate {
    
    private let viewModel: RMLocationDetailsViewViewModel
    
    private let detailsView = RMLocationDetailsView()
    
    // MARK: - Init
    
    init(location: RMLocation) {
        let url = URL(string: location.url)
        self.viewModel = RMLocationDetailsViewViewModel(endpointUrl: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Location"
        view.addSubview(detailsView)
        setUpConstraints()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
        
        viewModel.delegate = self // who gets notified as delegate once smth interesting happens and we make real implementation of delegate here as we rised hand and said I'm the delegate - ok but to be so you have to implement some functionality
        viewModel.fetchLocationData() // initailly we called this func from viewModel's init() but to avoid edge case when fetching happens faster than assigning viewModel's delegate (which is this VC)
        detailsView.delegate = self // delegate to open CharacterView from LocationDetailsView
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
        
    func didFetchLocationDetails() {
        detailsView.configure(with: viewModel) // once we get notified from ViewModel via delegate protocol that fetching of episodes done we set up our View UI
    }
    
    // MARK: - View Delegate
    
    func rmLocationDetailsView(_ locationDetailsView: RMLocationDetailsView, didSelectCharacter character: RMCharacter) {
        let vc = RMCharacterDetailsViewController(viewModel: .init(character: character))
        vc.title = character.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
