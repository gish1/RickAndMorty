//
//  Character+CoreDataProperties.swift
//  RickAndMorty
//
//  Created by Пк on 20.03.2020.
//  Copyright © 2020 Пк. All rights reserved.
//
//

import Foundation
import CoreData


extension Character {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Character> {
        return NSFetchRequest<Character>(entityName: "Character")
    }

    @NSManaged public var id: Int16
    @NSManaged public var imagePath: String?
    @NSManaged public var name: String?
    @NSManaged public var species: String?

}
