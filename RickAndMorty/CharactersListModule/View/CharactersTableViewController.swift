
//
//  CharactersTableViewController.swift
//  RickAndMorty
//
//  Created by Пк on 20.03.2020.
//  Copyright © 2020 Пк. All rights reserved.
//

import UIKit
import CoreData

class CharactersTableViewController: UITableViewController {
    
    var presentor:ViewToPresenterProtocol?
    let persistence = PersistenceService.shared
    let imageManager = ImageService.shared
    var timer: Timer?
    var newCount = 0

    var fetchedResultsController: NSFetchedResultsController<Character>!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        let view = self
        let presenter: ViewToPresenterProtocol & InteractorToPresenterProtocol = CharactersPresenter()
        let interactor: PresenterToInteractorProtocol = CharactersInteractor()
        
        view.presentor = presenter
        presenter.view = view
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        self.setupFetchedResultsController(for: self.persistence.context)
        self.presentor?.startFetchingCharacters()
    }

    func setupFetchedResultsController(for context:NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<Character>(entityName: "Character")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try controller.performFetch()
            self.fetchedResultsController = controller
            self.fetchedResultsController.delegate = self
            tableView.reloadData()
        } catch {
            fatalError("Failed to fetch entities: \(error)")
        }
    }

    func countObjects() -> Int {
        let count = fetchedResultsController.fetchedObjects!.count
        return count
    }

    func createAlertError(errorDescription: String) {
        let alertController = UIAlertController(title: "Error", message: errorDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.newCount = 0
            self.createReloadButton()
        }
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }

    func createReloadButton() {
        let reloadButton = UIButton(type: .custom)
        reloadButton.backgroundColor = UIColor.darkGray
        reloadButton.setTitle("Reload", for: .normal)
        reloadButton.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(30))
        
        self.tableView.tableFooterView = reloadButton
        self.tableView.tableFooterView?.isHidden = false
        reloadButton.addTarget(self, action: #selector(reloadAction(_:)), for: .touchUpInside)
    }

    @objc private func reloadAction(_ sender: UIButton?) {
        sender?.isEnabled = false
        self.presentor?.startFetchingCharacters()
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (_) in
            sender?.isEnabled = true
            sender?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tableView.bounds.width, height: CGFloat(0))
        })
    }
    

//MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections[section].numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil{
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        }
        
        guard let character = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("Attempt to configure cell without a managed object")
        }
                        
        cell?.textLabel?.text = character.name
        cell?.detailTextLabel?.text = character.species

        cell?.imageView?.image = nil
        if let imagePath = character.imagePath {
            cell?.imageView?.image = self.imageManager.getImage(imageName: imagePath)
        }
        
        return cell!
    }

//MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.newCount - 1  {
            newCount = 0
            
            let spinner = UIActivityIndicatorView(style:.medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(30))
            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
            
            self.presentor?.startFetchingCharacters()

            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false, block: { (_) in
                spinner.stopAnimating()
                self.tableView.beginUpdates()
                spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(0))
                self.tableView.endUpdates()
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//MARK: - PresenterToViewProtocol

extension CharactersTableViewController: PresenterToViewProtocol {

    func showCharacters() {
        self.newCount = self.countObjects()
    }
    
    func showError(errorDesctiption: String) {
        self.newCount = self.countObjects()
        DispatchQueue.main.async {
            self.createAlertError(errorDescription: errorDesctiption)
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate

extension CharactersTableViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,didChange anObject: Any,at indexPath: IndexPath?,for type: NSFetchedResultsChangeType,newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .move:
            tableView.reloadData()
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,didChange sectionInfo: NSFetchedResultsSectionInfo,atSectionIndex sectionIndex: Int,for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
}




