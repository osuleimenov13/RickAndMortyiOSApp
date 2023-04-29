//
//  RMSearchViewViewModel.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 19.04.2023.
//

import Foundation

// Responsibilities
// show search results
// - show no results view
// - kick off API requests

final class RMSearchViewViewModel {
    
    let config: RMSearchViewController.Config // view model already knows what we are going to search characters, locations or episodes
    
    private var optionMap: [RMSearchInputViewViewModel.DynamicOption: String] = [:] // holds if we have any query arguments (status, gender etc.)
    
    private var optionMapUpdateBlock: ((RMSearchInputViewViewModel.DynamicOption, String) -> Void)?
    private var searchText = ""
    
    private var searchResultHandler: ((RMSearchResultsViewModel) -> Void)?
    private var noResultsHandler: (() -> Void)?
    
    private var searchResultModel: Codable?

    // MARK: - Init
    
    init(config: RMSearchViewController.Config) {
        self.config = config
    }
    
    
    // MARK: - Public
    public func registerSearchResultHandler(_ block: @escaping (RMSearchResultsViewModel) -> Void) {
        self.searchResultHandler = block
    }
    
    public func registerNoResultsHandler(_ block: @escaping () -> Void) {
        self.noResultsHandler = block
    }
    
    public func executeSearch() {
        // Create Request based on filters
        // Send API Call
        // Notify view of results, no results, or error
        
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
                
        // Build query parameters
        var queryParams = [URLQueryItem(name: "name", value: searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))]
        
        // add more query parameters
        queryParams.append(contentsOf: optionMap.compactMap({ element in
            let key: RMSearchInputViewViewModel.DynamicOption = element.key
            let value: String = element.value
            return URLQueryItem(name: key.queryArgument, value: value)
        }))
        
        
        let request = RMRequest(
            endpoint: config.type.endpoint,
            queryParameters: queryParams)
        
        switch config.type.endpoint {
        case .character:
            makeSearchAPICall(RMGetAllCharactersResponse.self, request: request)
        case .episode:
            makeSearchAPICall(RMGetAllEpisodesResponse.self, request: request)
        case .location:
            makeSearchAPICall(RMGetAllLocationsResponse.self, request: request)
        }
    }
    
    private func makeSearchAPICall<T: Codable>(_ type: T.Type, request: RMRequest) {
        RMService.shared.execute(request, expecting: type) { [weak self] result in
            // Notify view of results, no results, or error
            switch result {
            case .success(let model):
                // Episodes, Characters: CollectionView; Locations: TableView
                self?.processSearchResults(model: model)
            case .failure:
                self?.handleNoResults()
            }
        }
    }
    
    private func processSearchResults(model: Codable) {
        var searchResultsOfType: RMSearchResultsType?
        var nextUrl: String?
        
        if let characterResults = model as? RMGetAllCharactersResponse {
            searchResultsOfType = .characters(characterResults.results.compactMap({
                return RMCharacterCollectionViewCellViewModel(
                    characterName: $0.name,
                    characterStatus: $0.status,
                    characterImageUrl: URL(string: $0.image))
            }))
            
            nextUrl = characterResults.info.next
        }
        else if let episodeResults = model as? RMGetAllEpisodesResponse {
            searchResultsOfType = .episodes(episodeResults.results.compactMap({
                return RMCharacterEpisodeCollectionViewCellViewModel(episodeDataUrl: URL(string: $0.url))
            }))
            
            nextUrl = episodeResults.info.next
        }
        else if let locationResults = model as? RMGetAllLocationsResponse {
            searchResultsOfType = .locations(locationResults.results.compactMap({
                return RMLocationTableViewCellViewModel(location: $0)
            }))
            
            nextUrl = locationResults.info.next
        }
        else {
            // Error: No results view
        }
        
        
        if let results = searchResultsOfType {
            self.searchResultModel = model
            let vm = RMSearchResultsViewModel(results: results, next: nextUrl)
            self.searchResultHandler?(vm)
        } else {
            // fallback error
            handleNoResults()
        }
    }
    
    private func handleNoResults() {
        print("No results")
        noResultsHandler?()
    }
    
    public func set(query text: String) { // to get typed for search information once hit Search button
        self.searchText = text
    }
    
    public func set(value: String, for option: RMSearchInputViewViewModel.DynamicOption) {
        optionMap[option] = value
        optionMapUpdateBlock?(option, value)
    }
    
    // this block is gonna return to us whatever we listen for
    public func registerOptionChangeBlock(_ block: @escaping (RMSearchInputViewViewModel.DynamicOption, String) -> Void) {
        self.optionMapUpdateBlock = block
    }
    
    public func locationSearchResult(at index: Int) -> RMLocation? {
        guard let searchModel = searchResultModel as? RMGetAllLocationsResponse else {
            return nil
        }
        return searchModel.results[index]
    }
}
