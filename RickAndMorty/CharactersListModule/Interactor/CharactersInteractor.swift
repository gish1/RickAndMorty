//
//  CharactersInteractor.swift
//  RickAndMortyTest
//
//  Created by Пк on 11.03.2020.
//  Copyright © 2020 Пк. All rights reserved.
//

import Foundation
import CoreData

class CharactersInteractor: PresenterToInteractorProtocol {
    
    var presenter: InteractorToPresenterProtocol?
    
    var newUpload = true
    var currentUrl : String = ""
    var nextUrl : String = "https://rickandmortyapi.com/api/character/"
    let persistence = PersistenceService.shared
    let network = NetworkService.shared
    let imageManager = ImageService.shared
    
    lazy var OperationQ: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 15
        return queue
    }()

    func requestData() {
        network.request(urlString: self.nextUrl) { (result) in
            switch result {
            case.success(let data):
                if self.newUpload {
                    self.persistence.deleteData(Character.self)
                    self.newUpload = false
                }
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
                    self.getCharacters(json: json) {
                        self.presenter?.charactersFetchedSuccess()
                    }
                }
            case.failure(let error):
                switch error.code {
                case -1009 :
                    self.presenter?.charactersFetchFailed(errorDesctiption: error.localizedDescription)
                default:
                    break
                }
            }
        }
    }
    
    func getCharacters(json: [String : Any],completion: @escaping()-> Void) {
        if let result = json["results"] as? [[String:Any]] {
            let infoJson = json["info"] as! [String : Any]
            let nextURL = infoJson["next"] as! String
            if nextUrl != currentUrl {
                currentUrl = nextUrl
                nextUrl = nextURL
                                                        
                for info in result {
                    let character = Character(context: (self.persistence.context))
                    character.id = (info["id"] as? Int16)!
                    character.name = info["name"] as? String
                    character.species = info["species"] as? String
                    
                    self.OperationQ.addOperation {
                        self.imageManager.getImageData(string: info["image"] as! String) { (data) in
                            DispatchQueue.main.async {
                                character.imagePath = self.imageManager.saveImage(image: data)
                            }
                        }
                    }
                }
            }
            self.persistence.save()
        }
        completion()
    }
}
    
//MARK: - extensionError

extension Error {
    
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}



