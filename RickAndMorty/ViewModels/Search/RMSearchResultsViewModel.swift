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


enum RMSearchResultsViewModel {
    case characters([RMCharacterCollectionViewCellViewModel])
    case episodes([RMCharacterEpisodeCollectionViewCellViewModel])
    case locations([RMLocationTableViewCellViewModel])
}
