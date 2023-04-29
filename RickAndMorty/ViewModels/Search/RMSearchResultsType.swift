//
//  RMSearchResultsViewModel.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 24.04.2023.
//

import Foundation

//protocol RMSearchResultRepresentable {
//    associatedtype ResultType
//    var results: [ResultType] { get }
//}
//
//struct RMSearchResultsViewModel<T>: RMSearchResultRepresentable { // should hold our results in generic way
//    // when we instantiate this struct its gonna say pass in whatever collection of results you have and that's what its going to use as a backing for the generic
//    typealias ResultType = T
//    var results: [ResultType]
//}

final class RMSearchResultsViewModel {
    public private (set) var results: RMSearchResultsType
    var next: String?
    
    init(results: RMSearchResultsType, next: String?) {
        self.results = results
        self.next = next
    }
    
    public private (set) var isLoadingMoreResults = false
    public var shouldShowLoadMoreIndicator: Bool {
        return next != nil
    }
    
    /// Paginate if additional locations are needed
    public func fetchAdditionalLocations(completion: @escaping ([RMLocationTableViewCellViewModel]) -> Void) {
        guard !isLoadingMoreResults else {
            return
        }
        
        guard let nextUrlString = next,
              let url = URL(string: nextUrlString),
              let request = RMRequest(url: url) else {
            isLoadingMoreResults = false
            print("Failed to create request")
            return
        }
        
        isLoadingMoreResults = true
        print("Fetching more locations")
        
        RMService.shared.execute(request, expecting: RMGetAllLocationsResponse.self) { [weak self] result in
            guard let strongSelf = self else { return }
        
            switch result {
            case .success(let responseModel):
                let moreResults = responseModel.results
                strongSelf.next = responseModel.info.next // Capture new pagination url
                
                let additionalLocations = moreResults.compactMap({
                    return RMLocationTableViewCellViewModel(location: $0)
                })
                   
                var newResults: [RMLocationTableViewCellViewModel] = []
                switch strongSelf.results {
                case .locations(let existingResults):
                    newResults = existingResults + additionalLocations
                    strongSelf.results = .locations(newResults)
                case .characters, .episodes:
                    break
                }
                
                
                DispatchQueue.main.async {
                    strongSelf.isLoadingMoreResults = false
                    
                    // Notify UI to update itself via callback
                    completion(newResults)
                }
                
                
            case .failure(_):
                strongSelf.isLoadingMoreResults = false
            }
        }
    }
    
    /// Paginate if additional characters/episodes are needed
    public func fetchAdditionalResults(completion: @escaping ([any Hashable]) -> Void) {
        guard !isLoadingMoreResults else {
            return
        }
        
        guard let nextUrlString = next,
              let url = URL(string: nextUrlString),
              let request = RMRequest(url: url) else {
            isLoadingMoreResults = false
            print("Failed to create request")
            return
        }
        
        isLoadingMoreResults = true
        print("Fetching more locations")
        
        switch results {
        case .characters(let existingResults):
            RMService.shared.execute(request, expecting: RMGetAllCharactersResponse.self) { [weak self] result in
                guard let strongSelf = self else { return }
            
                switch result {
                case .success(let responseModel):
                    let moreResults = responseModel.results
                    strongSelf.next = responseModel.info.next // Capture new pagination url
                    
                    let additionalResults = moreResults.compactMap({
                        return RMCharacterCollectionViewCellViewModel(
                            characterName: $0.name,
                            characterStatus: $0.status,
                            characterImageUrl: URL(string: $0.image))
                    })
                       
                    var newResults: [RMCharacterCollectionViewCellViewModel] = []
                    newResults = existingResults + additionalResults
                    strongSelf.results = .characters(newResults)
                    
                    DispatchQueue.main.async {
                        strongSelf.isLoadingMoreResults = false
                        
                        // Notify UI to update itself via callback
                        completion(newResults)
                    }
                    
                    
                case .failure(_):
                    strongSelf.isLoadingMoreResults = false
                }
            }
        case .episodes(let existingResults):
            RMService.shared.execute(request, expecting: RMGetAllEpisodesResponse.self) { [weak self] result in
                guard let strongSelf = self else { return }
            
                switch result {
                case .success(let responseModel):
                    let moreResults = responseModel.results
                    strongSelf.next = responseModel.info.next // Capture new pagination url
                    
                    let additionalResults = moreResults.compactMap({
                        return RMCharacterEpisodeCollectionViewCellViewModel(episodeDataUrl: URL(string: $0.url))
                    })
                       
                    var newResults: [RMCharacterEpisodeCollectionViewCellViewModel] = []
                    newResults = existingResults + additionalResults
                    strongSelf.results = .episodes(newResults)
                    
                    DispatchQueue.main.async {
                        strongSelf.isLoadingMoreResults = false
                        
                        // Notify UI to update itself via callback
                        completion(newResults)
                    }
                    
                    
                case .failure(_):
                    strongSelf.isLoadingMoreResults = false
                }
            }
        case .locations:
            // TableView, shouldn't get here anyway
            break
        }
        
        
    }
}


enum RMSearchResultsType {
    case characters([RMCharacterCollectionViewCellViewModel])
    case episodes([RMCharacterEpisodeCollectionViewCellViewModel])
    case locations([RMLocationTableViewCellViewModel])
}
