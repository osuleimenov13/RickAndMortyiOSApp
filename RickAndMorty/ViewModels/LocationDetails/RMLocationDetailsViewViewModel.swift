//
//  RMLocationDetailsViewViewModel.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 18.04.2023.
//

import Foundation


protocol RMLocationDetailsViewViewModelDelegate:AnyObject {
    func didFetchLocationDetails()
    
}

final class RMLocationDetailsViewViewModel {
    
    private let endpointUrl: URL?
    
    public weak var delegate: RMLocationDetailsViewViewModelDelegate?
    
    private var dataTuple: (location: RMLocation, characters: [RMCharacter])? {
        didSet {
            createCellViewModels()
            delegate?.didFetchLocationDetails() // will notify delegate (which will be View Controller in this case) that fetching done and start rendering UI of View
        }
    }
    
    enum SectionType {
        case information(viewModels: [RMEpisodeInfoCollectionViewCellViewModel])
        case characters(viewModel: [RMCharacterCollectionViewCellViewModel])
    }
    
    public private(set) var cellViewModels: [SectionType] = []
    
    // MARK: - Init
    
    init(endpointUrl: URL?) {
        self.endpointUrl = endpointUrl
    }
    
    // MARK: - Public
    public func character(at index: Int) -> RMCharacter? { // gets actual character when user taps on character cell
        guard let dataTuple = dataTuple else {
            return nil
        }
        return dataTuple.characters[index]
    }
    
    // MARK: - Private
    
    private func createCellViewModels() {
        guard let dataTuple = dataTuple else {
            return
        }
        let location = dataTuple.location
        let characters = dataTuple.characters
        var dateOfCreation = location.created
        if let date = RMCharacterInfoCollectionViewCellViewModel.dateFormatter.date(from: location.created) {
            dateOfCreation = RMCharacterInfoCollectionViewCellViewModel.shortDateFormatter.string(from: date)
        }
        
        
        cellViewModels = [
            .information(viewModels: [
                .init(title: "Location Name", value: location.name),
                .init(title: "Type", value: location.type),
                .init(title: "Dimension", value: location.dimension),
                .init(title: "Created", value: dateOfCreation)
            ]),
            .characters(viewModel: characters.compactMap({
                RMCharacterCollectionViewCellViewModel(
                    characterName: $0.name,
                    characterStatus: $0.status,
                    characterImageUrl: URL(string: $0.image))
            }))
        ]
    }
    
    /// Fetch backing location model
    public func fetchLocationData() {
        guard let url = endpointUrl, let request = RMRequest(url: url) else {
            return
        }
        
        RMService.shared.execute(request, expecting: RMLocation.self) { [weak self] result in
            switch result {
            case .success(let location):
                self?.fetchRelatedCharacters(location: location)
            case .failure:
                break
            }
        }
    }
    
    private func fetchRelatedCharacters(location: RMLocation) {
        let characerUrls: [URL] = location.residents.compactMap({
            return URL(string: $0)
        })
        let requests: [RMRequest] = characerUrls.compactMap({
            return RMRequest(url: $0)
        })
        
        // dispatch groups allow us to kick off any number or parallel requests
        // and we get Notified once it done (we don't know the order which will come back to us)
        
        let group = DispatchGroup()
        var characters: [RMCharacter] = []
        
        for request in requests {
            group.enter() // meaning something has started +1 ... +20
            RMService.shared.execute(request, expecting: RMCharacter.self) { result in
                defer {
                    group.leave() // -20 and once hit 0 it knows we have nothing left to do
                }
                switch result {
                case .success(let model):
                    characters.append(model)
                case .failure:
                    break
                }
            }
        }
        
        // once nothing left to do we wanna be notified we done
        group.notify(queue: .main) {
            self.dataTuple = (location: location, characters: characters)
        }
        
    }
    
    
}
