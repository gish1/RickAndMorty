//
//  PersistenceService.swift
//  RickAndMorty
//
//  Created by Пк on 20.03.2020.
//  Copyright © 2020 Пк. All rights reserved.
//

import Foundation
import CoreData

class PersistenceService {
    
    private init() {}
    static let shared = PersistenceService()

    var context: NSManagedObjectContext { return persistentContainer.viewContext }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RickAndMorty")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteData<T: NSManagedObject>(_ type: T.Type) {
        let reques = NSFetchRequest<T>(entityName: String(describing: type))
        reques.includesPropertyValues = false
        
         do {
            let results = try context.fetch(reques)
            for result in results {
                context.delete(result)
            }
            try context.save()
        } catch {
            print("fetch error -\(error.localizedDescription)")
        }
    }
}
