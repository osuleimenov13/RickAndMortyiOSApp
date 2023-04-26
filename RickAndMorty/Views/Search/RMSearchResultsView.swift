//
//  RMSearchResultsView.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 25.04.2023.
//

import UIKit

protocol RMSearchResultsViewDelegate: AnyObject {
    func rmSearchResultsView(_ resultsView: RMSearchResultsView, didTapLocationAt index: Int)
}

/// Shows search results UI (table or collection as needed)
final class RMSearchResultsView: UIView {
    
    weak var delegate: RMSearchResultsViewDelegate?
    
    private var viewModel: RMSearchResultsViewModel? {
        didSet {
            processViewModel()
        }
    }
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(RMLocationTableViewCell.self,
                        forCellReuseIdentifier: RMLocationTableViewCell.identifier)
        table.isHidden = true
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isHidden = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            RMCharacterCollectionViewCell.self,
            forCellWithReuseIdentifier: RMCharacterCollectionViewCell.identifier)
        collectionView.register(RMCharacterEpisodeCollectionViewCell.self, forCellWithReuseIdentifier: RMCharacterEpisodeCollectionViewCell.identifier)
        collectionView.register(
            RMFooterLoadingCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier)
        
        return collectionView
    }()
    
    
    private var locationCellViewModels: [RMLocationTableViewCellViewModel] = []
    private var collectionViewCellViewModels: [any Hashable] = []

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true
        backgroundColor = .red
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(tableView, collectionView)
        addConstraints() // need to add as subview first then set constraints otherwise app crashs
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
        tableView.topAnchor.constraint(equalTo: topAnchor),
        tableView.leftAnchor.constraint(equalTo: leftAnchor),
        tableView.rightAnchor.constraint(equalTo: rightAnchor),
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
        
        collectionView.topAnchor.constraint(equalTo: topAnchor),
        collectionView.leftAnchor.constraint(equalTo: leftAnchor),
        collectionView.rightAnchor.constraint(equalTo: rightAnchor),
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    private func processViewModel() {
        guard let viewModel = viewModel else {
            return
        }
        
        switch viewModel {
        case .characters(let viewModels):
            self.collectionViewCellViewModels = viewModels
            setUpCollectionView()
        case .episodes(let viewModels):
            self.collectionViewCellViewModels = viewModels
            setUpCollectionView()
        case .locations(let viewModels):
            setUpTableView(viewModels: viewModels)
        }
    }
    
    private func setUpCollectionView() {
        self.tableView.isHidden = true
        self.collectionView.isHidden = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    private func setUpTableView(viewModels: [RMLocationTableViewCellViewModel]) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = false
        collectionView.isHidden = true
        self.locationCellViewModels = viewModels
        tableView.reloadData()
    }
    
    public func configure(with viewModel: RMSearchResultsViewModel) {
        self.viewModel = viewModel
    }
    
    
}

// MARK: - TableView

extension RMSearchResultsView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationCellViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RMLocationTableViewCell.identifier,
                                                        for: indexPath) as? RMLocationTableViewCell else {
            fatalError("Failed to dequeue RMLocationTableViewCell")
        }
        cell.configure(with: locationCellViewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.rmSearchResultsView(self, didTapLocationAt: indexPath.row)
    }
}


// MARK: - CollectionView

extension RMSearchResultsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellViewModel = collectionViewCellViewModels[indexPath.row] // cause if we call this func means we have something in the array
        
        // Character cell
        if cellViewModel is RMCharacterCollectionViewCellViewModel {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterCollectionViewCell.identifier, for: indexPath) as? RMCharacterCollectionViewCell else { fatalError() }
            cell.configure(with: cellViewModel as! RMCharacterCollectionViewCellViewModel)
            return cell
        }
        
        // Episode cell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterEpisodeCollectionViewCell.identifier, for: indexPath) as? RMCharacterEpisodeCollectionViewCell else { fatalError() }
        
        if let episodeVM = cellViewModel as? RMCharacterEpisodeCollectionViewCellViewModel {
            cell.configure(with: episodeVM)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellViewModel = collectionViewCellViewModels[indexPath.row]
        let bounds = UIScreen.main.bounds
        
        if cellViewModel is RMCharacterCollectionViewCellViewModel {
            // Character size
            let width = (bounds.width-30)/2
            
            return CGSize(
                width: width,
                height: width * 1.5
            )
        }
        
        // Episode size
        let width = bounds.width-20
        
        return CGSize(
            width: width,
            height: 100
        )
    }
}
