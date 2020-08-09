//
//  CharactersPresenter.swift
//  RickAndMorty
//
//  Created by Пк on 21.03.2020.
//  Copyright © 2020 Пк. All rights reserved.
//

import Foundation
import UIKit

class CharactersPresenter: ViewToPresenterProtocol {
    
    var view: PresenterToViewProtocol?
    var interactor: PresenterToInteractorProtocol?
    
    func startFetchingCharacters() {
        interactor?.requestData()
    }
}

//MARK: - InteractorToPresenterProtocol

extension CharactersPresenter: InteractorToPresenterProtocol {
    
    func charactersFetchFailed(errorDesctiption: String) {
        view?.showError(errorDesctiption: errorDesctiption)
    }
    
    func charactersFetchedSuccess() {
        view?.showCharacters()
    }
}
