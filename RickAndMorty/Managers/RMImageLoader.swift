//
//  ImageManager.swift
//  RickAndMorty
//
//  Created by Olzhas Suleimenov on 03.03.2023.
//

import Foundation

final class RMImageLoader {
    
    static let shared = RMImageLoader()

    private init() {}
            
    // NSCache intellegently getting rid of caches during the App session in case memorty getting low
    private var imageDataCache = NSCache<NSString, NSData>()
    
    /// Get image content with URL
    /// - Parameters:
    ///   - url: Source url
    ///   - completion: Callback
    public func downloadImage(_ url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let key = url.absoluteString as NSString
        if let data = imageDataCache.object(forKey: key) {
            //print("Reading from cache: \(key)")
            completion(.success(data as Data))
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? URLError(.badServerResponse)))
                return
            }
            
            let value = data as NSData
            self?.imageDataCache.setObject(value, forKey: key)
            
            completion(.success(data))
        }
        task.resume()
    }
}
