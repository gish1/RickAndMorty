//
//  CharactersProtocols.swift
//  RickAndMorty
//
//  Created by Пк on 21.03.2020.
//  Copyright © 2020 Пк. All rights reserved.
//

import Foundation

protocol ViewToPresenterProtocol: class {
    var view: PresenterToViewProtocol? {get set}
    var interactor: PresenterToInteractorProtocol? {get set}
    func startFetchingCharacters()
}

protocol PresenterToViewProtocol: class {
    func showCharacters()
    func showError(errorDesctiption: String)
}

protocol PresenterToInteractorProtocol: class {
    var presenter:InteractorToPresenterProtocol? {get set}
    func requestData()
}

protocol InteractorToPresenterProtocol: class {
    func charactersFetchedSuccess()
    func charactersFetchFailed(errorDesctiption: String)
}
