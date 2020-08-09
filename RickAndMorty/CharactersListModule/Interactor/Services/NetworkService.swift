//
//  NetworkService.swift
//  RickAndMortyTest
//
//  Created by Пк on 08.03.2020.
//  Copyright © 2020 Пк. All rights reserved.
//

import Foundation

class NetworkService {
        
    private init() {}
    static let shared = NetworkService()
    
    func request(urlString: String, completeion: @escaping (Result<Data, Error>)-> Void) {
        guard let url = URL(string: urlString) else { return }
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil

        let session = URLSession.init(configuration: config)
        session.dataTask(with: url) {(data, response, error) in
                if let error = error{
                    completeion(.failure(error))
                    return
                }
                guard let data = data else { return }
                    completeion(.success(data))
        }.resume()
    }
}
